//
//  NeonGlowView.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import MetalKit
import QuartzCore
import UIKit
import simd

private let neonShaderSource = """
#include <metal_stdlib>
using namespace metal;

struct VertexOut { float4 position [[position]]; float2 uv; };

vertex VertexOut neonVtx(uint vid [[vertex_id]]) {
    float2 p[3] = {float2(-1,-3), float2(-1,1), float2(3,1)};
    VertexOut o; o.position = float4(p[vid],0,1);
    o.uv = p[vid]*0.5+0.5; o.uv.y = 1.0-o.uv.y; return o;
}

struct U {
    float2 resolution; float2 animOrigin;
    float time; float borderWidth; float cornerRadius;
    float glowInner; float glowOuter; float glowIntensity;
    int animType; float animProgress;
    float lensRingIntensity; int hasBgTex;
};

float sdRoundBox(float2 p, float2 b, float r) {
    float2 q = abs(p)-b+r;
    return length(max(q,float2(0)))+min(max(q.x,q.y),0.0)-r;
}

float3 hsv2rgb(float3 c) {
    float4 K = float4(1,2.0/3.0,1.0/3.0,3);
    float3 p = abs(fract(c.xxx+K.xyz)*6.0-K.www);
    return c.z*mix(K.xxx,saturate(p-K.xxx),c.y);
}

float perimPos(float2 p) {
    return fract(atan2(-p.x, -p.y) / (2.0*M_PI_F) + 0.5);
}

fragment float4 neonFrag(VertexOut in [[stage_in]],
                         constant U &u [[buffer(0)]],
                         texture2d<float> bgTex [[texture(0)]]) {
    float2 px = in.uv * u.resolution;
    float2 center = u.resolution * 0.5;
    float2 p = px - center;
    float2 half_c = center - float2(u.glowOuter);
    float prog = u.animProgress;
    float2 sampleP = p;
    float extraBright = 0.0;
    float2 bgDisplace = float2(0);

    if (u.animType == 3 && prog < 0.999) {
        float2 origin = u.animOrigin - center;
        float2 toP = p - origin;
        float dist = length(toP);
        float maxR = length(u.resolution);
        float revealR = prog * maxR;
        float lensW = max(120.0, u.resolution.x * 0.25);
        float edge = dist - revealR;
        if (edge > lensW * 1.2) return float4(0);
        if (dist > 0.001) {
            float2 dir = normalize(toP);
            float decay = pow(1.0 - prog, 1.5);
            float env = exp(-edge*edge / (lensW*lensW*0.5));
            float wave = sin(saturate((edge + lensW) / (2.0*lensW)) * M_PI_F) * env * 50.0 * decay;
            bgDisplace = dir * wave;
        }
        float ringDist = abs(edge);
        float decay2 = pow(1.0 - prog, 2.0);
        extraBright = exp(-ringDist*ringDist / (lensW*lensW*0.06))
                    * u.lensRingIntensity * decay2;
    }

    if (u.animType == 2 && prog < 0.999) {
        float2 origin = u.animOrigin - center;
        float2 toP = p - origin;
        float dist = length(toP);
        float maxR = length(u.resolution) * 1.1;
        float waveR = prog * maxR;
        float waveW = 60.0;
        if (dist > 0.001) {
            float2 dir = normalize(toP);
            float waveDist = dist - waveR;
            float decay = 1.0 - prog;
            float env1 = exp(-waveDist*waveDist / (waveW*waveW*1.5));
            float ripple1 = sin(waveDist * 0.15) * env1 * 40.0 * decay;
            float preDist = dist - (waveR + waveW * 3.0);
            float env2 = exp(-preDist*preDist / (waveW*waveW*0.5));
            float ripple2 = sin(preDist * 0.25) * env2 * 15.0 * decay;
            float tailDist = dist - max(waveR - waveW * 3.0, 0.0);
            float env3 = exp(-tailDist*tailDist / (waveW*waveW*0.8));
            float ripple3 = sin(tailDist * 0.2) * env3 * 10.0 * decay;
            bgDisplace = dir * (ripple1 + ripple2 + ripple3);
        }
    }

    float d = sdRoundBox(sampleP, half_c, u.cornerRadius);
    float angle = atan2(sampleP.y, sampleP.x);
    float hue = fract(angle / (2.0*M_PI_F) + 0.5 + u.time);
    float3 color = hsv2rgb(float3(hue, 0.75, 1.0));

    float halfBW = u.borderWidth * 0.5;
    float borderA = 1.0 - smoothstep(-0.5, 1.0, abs(d) - halfBW);
    float glowDist = max(abs(d) - halfBW, 0.0);
    float sigma = (d < 0.0) ? (u.glowInner*0.38) : (u.glowOuter*0.38);
    float glowA = exp(-(glowDist*glowDist) / max(2.0*sigma*sigma, 0.001)) * u.glowIntensity;
    float baseAlpha = max(borderA, glowA);
    float nA = saturate(baseAlpha + extraBright);
    float3 neonColor = mix(color, float3(1.0), saturate(extraBright));
    float nearBorder = saturate(baseAlpha * 3.0);

    float mask = 1.0;

    if (u.animType == 1) {
        mask = prog;
    } else if (u.animType == 2) {
        float2 origin = u.animOrigin - center;
        float dist = length(p - origin);
        float maxR = length(u.resolution) * 1.1;
        float waveR = prog * maxR;
        float waveW = 50.0;
        mask = 1.0 - smoothstep(waveR - waveW * 0.3, waveR + waveW, dist);
        float ring1 = exp(-pow(dist - waveR, 2.0) / (waveW*waveW*0.5)) * 2.0;
        float preR = waveR + waveW * 1.5;
        float ring2 = exp(-pow(dist - preR, 2.0) / (waveW*waveW*0.3)) * 0.6;
        float tailR = max(waveR - waveW * 2.0, 0.0);
        float ring3 = exp(-pow(dist - tailR, 2.0) / (waveW*waveW*0.8)) * 0.3;
        float rings = ring1 + ring2 + ring3;
        nA = saturate(nA * mask + rings * nearBorder);
        neonColor = mix(neonColor, float3(1.0), saturate(rings * nearBorder * 0.5));
        mask = 1.0;
    } else if (u.animType == 3) {
        float2 origin = u.animOrigin - center;
        float dist = length(p - origin);
        float maxR = length(u.resolution);
        float revealR = prog * maxR;
        float lensW = max(120.0, u.resolution.x * 0.25);
        mask = 1.0 - smoothstep(revealR - lensW * 0.2, revealR + lensW, dist);
        float waveFrontDist = abs(dist - revealR);
        float waveBright = exp(-waveFrontDist*waveFrontDist / (lensW*lensW*0.15))
                         * nearBorder * 2.5 * pow(1.0 - prog, 1.5);
        nA = saturate(nA * mask + waveBright);
        neonColor = mix(neonColor, float3(1.0), saturate(waveBright * 0.6));
        mask = 1.0;
    } else if (u.animType == 4) {
        float pos = perimPos(sampleP);
        float head = prog;
        float behind = fract(head - pos);
        float trailMask = 1.0 - smoothstep(head, head + 0.02, behind);
        float headDiff = pos - head;
        if (headDiff > 0.5) headDiff -= 1.0;
        if (headDiff < -0.5) headDiff += 1.0;
        float headGlow = exp(-headDiff*headDiff / 0.0002) * 3.0 * nearBorder;
        headGlow *= 1.0 - smoothstep(0.85, 0.98, prog);
        float freshness = 1.0 - behind * 0.2;
        nA = saturate(nA * trailMask * freshness + headGlow);
        neonColor = mix(neonColor, float3(1.0), saturate(headGlow * 0.5));
        mask = 1.0;
    }

    nA *= mask;

    float dispLen = length(bgDisplace);
    if (u.hasBgTex != 0 && dispLen > 0.3) {
        constexpr sampler s(filter::linear, address::clamp_to_edge);
        float2 contentOrigin = float2(u.glowOuter);
        float2 contentSize = u.resolution - 2.0 * contentOrigin;
        float2 bgUV = (px + bgDisplace - contentOrigin) / contentSize;
        bgUV = saturate(bgUV);
        float4 bg = bgTex.sample(s, bgUV);
        float dM = saturate(dispLen * 0.03);
        float combinedA = dM + nA - dM * nA;
        float3 premulRGB = bg.rgb * dM * (1.0 - nA) + neonColor * nA;
        if (combinedA < 0.001) return float4(0);
        return float4(premulRGB, combinedA);
    }

    if (nA < 0.001) return float4(0);
    return float4(neonColor * nA, nA);
}
"""

private struct NeonUniforms {
    var resolution: SIMD2<Float>
    var animOrigin: SIMD2<Float>
    var time: Float
    var borderWidth: Float
    var cornerRadius: Float
    var glowInner: Float
    var glowOuter: Float
    var glowIntensity: Float
    var animType: Int32
    var animProgress: Float
    var lensRingIntensity: Float
    var hasBgTexture: Int32
}

public final class NeonGlowView: UIView, MTKViewDelegate {
    public var configuration: NeonGlowConfiguration = .init() {
        didSet { applyConfiguration() }
    }

    public var neonBorderWidth: CGFloat {
        get { configuration.neonBorderWidth }
        set {
            configuration.neonBorderWidth = newValue
            applyConfiguration()
        }
    }

    public var neonCornerRadius: CGFloat {
        get { configuration.neonCornerRadius }
        set {
            configuration.neonCornerRadius = newValue
            if !isUpdatingScreenCornerRadius {
                configuration.matchesScreenCornerRadius = false
            }
            applyConfiguration()
        }
    }

    public var matchesScreenCornerRadius: Bool {
        get { configuration.matchesScreenCornerRadius }
        set {
            configuration.matchesScreenCornerRadius = newValue
            if newValue {
                isUpdatingScreenCornerRadius = true
                configuration.neonCornerRadius = ScreenGeometry.displayCornerRadiusForCurrentDevice()
                isUpdatingScreenCornerRadius = false
            }
            applyConfiguration()
        }
    }

    public var glowInnerSpread: CGFloat {
        get { configuration.glowInnerSpread }
        set {
            configuration.glowInnerSpread = newValue
            applyConfiguration()
        }
    }

    public var glowOuterSpread: CGFloat {
        get { configuration.glowOuterSpread }
        set {
            configuration.glowOuterSpread = newValue
            applyConfiguration()
        }
    }

    public var glowIntensity: CGFloat {
        get { configuration.glowIntensity }
        set {
            configuration.glowIntensity = newValue
            applyConfiguration()
        }
    }

    public var lensRingIntensity: CGFloat {
        get { configuration.lensRingIntensity }
        set {
            configuration.lensRingIntensity = newValue
            applyConfiguration()
        }
    }

    public var flowSpeed: CGFloat {
        get { configuration.flowSpeed }
        set {
            configuration.flowSpeed = newValue
            applyConfiguration()
        }
    }

    public var animationSpeedMultiplier: CGFloat {
        get { configuration.animationSpeedMultiplier }
        set {
            configuration.animationSpeedMultiplier = newValue
            applyConfiguration()
        }
    }

    private let metalView: MTKView
    private let deviceRef: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var pipeline: MTLRenderPipelineState?
    private var backgroundTexture: MTLTexture?
    private var dummyTexture: MTLTexture?

    private var lastTime: CFTimeInterval = 0
    private var flowTime: Float = 0
    private var isFlowingInternal = false
    private var animType: Int32 = 0
    private var animProgress: Float = 1
    private var animOrigin = SIMD2<Float>(0.5, 0.5)
    private var animStartTime: CFTimeInterval = 0
    private var animDuration: TimeInterval = 0.01
    private var animForward = true
    private var animCompletion: (() -> Void)?
    private var isUpdatingScreenCornerRadius = false

    public override init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        deviceRef = device
        metalView = MTKView(frame: .zero, device: device)
        super.init(frame: frame)
        defaultConfiguration()
        setupMetal()
    }

    public required init?(coder: NSCoder) {
        let device = MTLCreateSystemDefaultDevice()
        deviceRef = device
        metalView = MTKView(frame: .zero, device: device)
        super.init(coder: coder)
        defaultConfiguration()
        setupMetal()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    public func prepareDistortion(with sourceView: UIView) {
        guard let deviceRef, sourceView.bounds.width >= 1, sourceView.bounds.height >= 1 else {
            return
        }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: sourceView.bounds.size, format: format)
        let image = renderer.image { _ in
            sourceView.drawHierarchy(in: sourceView.bounds, afterScreenUpdates: false)
        }

        do {
            let loader = MTKTextureLoader(device: deviceRef)
            backgroundTexture = try loader.newTexture(
                cgImage: image.cgImage!,
                options: [MTKTextureLoader.Option.SRGB: false]
            )
        } catch {
            print("Neon background texture error: \(error)")
        }
    }

    public func clearDistortionSource() {
        backgroundTexture = nil
    }

    public func startFlowing() {
        isFlowingInternal = true
        ensureRunning()
    }

    public func stopFlowing() {
        isFlowingInternal = false
        checkPause()
    }

    public func show(
        animation: NeonGlowAnimation,
        duration: TimeInterval,
        from normalizedPoint: CGPoint,
        completion: (() -> Void)? = nil
    ) {
        isHidden = false
        lastTime = 0
        animType = Int32(animation.rawValueIndex)
        animProgress = 0
        animForward = true
        animDuration = max(duration / max(configuration.animationSpeedMultiplier, 0.1), 0.01)
        animStartTime = CACurrentMediaTime()
        animCompletion = completion
        animOrigin = SIMD2<Float>(
            Float(min(max(normalizedPoint.x, 0), 1)),
            Float(min(max(normalizedPoint.y, 0), 1))
        )
        metalView.draw()
        ensureRunning()
    }

    public func dismiss(
        animation: NeonGlowAnimation,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        animType = Int32(animation.rawValueIndex)
        animProgress = 1
        animForward = false
        animDuration = max(duration / max(configuration.animationSpeedMultiplier, 0.1), 0.01)
        animStartTime = CACurrentMediaTime()
        animCompletion = completion
        ensureRunning()
    }

    private func defaultConfiguration() {
        configuration = .init()
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    private func setupMetal() {
        guard let deviceRef else { return }

        metalView.delegate = self
        metalView.frame = bounds
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.clearColor = MTLClearColorMake(0, 0, 0, 0)
        metalView.isOpaque = false
        metalView.layer.isOpaque = false
        metalView.backgroundColor = .clear
        metalView.preferredFramesPerSecond = 60
        metalView.isPaused = true
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(metalView)

        commandQueue = deviceRef.makeCommandQueue()

        do {
            let library = try deviceRef.makeLibrary(source: neonShaderSource, options: nil)
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: "neonVtx")
            descriptor.fragmentFunction = library.makeFunction(name: "neonFrag")
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            pipeline = try deviceRef.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Neon pipeline error: \(error)")
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: 1,
            height: 1,
            mipmapped: false
        )
        dummyTexture = deviceRef.makeTexture(descriptor: textureDescriptor)
    }

    private func applyConfiguration() {
        if configuration.matchesScreenCornerRadius && !isUpdatingScreenCornerRadius {
            isUpdatingScreenCornerRadius = true
            configuration.neonCornerRadius = ScreenGeometry.displayCornerRadiusForCurrentDevice()
            isUpdatingScreenCornerRadius = false
        }
        metalView.setNeedsDisplay()
    }

    private func ensureRunning() {
        metalView.isPaused = false
    }

    private func checkPause() {
        guard !isFlowingInternal, animType == 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }
            if !self.isFlowingInternal, self.animType == 0 {
                self.metalView.isPaused = true
            }
        }
    }

    private func updateAnimationProgress() {
        guard animType != 0 else { return }

        let elapsed = CACurrentMediaTime() - animStartTime
        var t = min(Float(elapsed / animDuration), 1)
        t = t * t * (3 - 2 * t)
        animProgress = animForward ? t : (1 - t)

        guard elapsed >= animDuration else { return }

        animProgress = animForward ? 1 : 0
        if !animForward {
            isHidden = true
        }
        animType = 0
        let completion = animCompletion
        animCompletion = nil
        checkPause()
        completion?()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard let pipeline,
              let commandQueue,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let now = CACurrentMediaTime()
        if isFlowingInternal, lastTime > 0 {
            flowTime += Float(now - lastTime) * Float(configuration.flowSpeed)
            if flowTime > 1 {
                flowTime -= 1
            }
        }
        lastTime = now
        updateAnimationProgress()

        let drawableSize = view.drawableSize
        let scale = view.contentScaleFactor
        let hasBackgroundTexture = backgroundTexture != nil
        var uniforms = NeonUniforms(
            resolution: SIMD2(Float(drawableSize.width), Float(drawableSize.height)),
            animOrigin: SIMD2(animOrigin.x * Float(drawableSize.width), animOrigin.y * Float(drawableSize.height)),
            time: flowTime,
            borderWidth: Float(configuration.neonBorderWidth * scale),
            cornerRadius: Float(configuration.neonCornerRadius * scale),
            glowInner: Float(configuration.glowInnerSpread * scale),
            glowOuter: Float(configuration.glowOuterSpread * scale),
            glowIntensity: Float(configuration.glowIntensity),
            animType: animType,
            animProgress: animProgress,
            lensRingIntensity: Float(configuration.lensRingIntensity),
            hasBgTexture: hasBackgroundTexture ? 1 : 0
        )

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<NeonUniforms>.stride, index: 0)
        encoder.setFragmentTexture(hasBackgroundTexture ? backgroundTexture : dummyTexture, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
}

private extension NeonGlowAnimation {
    var rawValueIndex: Int {
        switch self {
        case .none: return 0
        case .fade: return 1
        case .wave: return 2
        case .lens: return 3
        case .trace: return 4
        }
    }
}
