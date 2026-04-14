//
//  NGNeonGlowView.m
//  NeonGlowObjC
//
//  Created by 李琢 on 2026/04/14.
//

#import "NGNeonGlowView.h"
#import "NGScreenGeometry.h"
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>

static NSString *const kShaderSource = @""
"#include <metal_stdlib>\n"
"using namespace metal;\n"
"\n"
"struct VertexOut { float4 position [[position]]; float2 uv; };\n"
"\n"
"vertex VertexOut neonVtx(uint vid [[vertex_id]]) {\n"
"    float2 p[3] = {float2(-1,-3), float2(-1,1), float2(3,1)};\n"
"    VertexOut o; o.position = float4(p[vid],0,1);\n"
"    o.uv = p[vid]*0.5+0.5; o.uv.y = 1.0-o.uv.y; return o;\n"
"}\n"
"\n"
"struct U {\n"
"    float2 resolution; float2 animOrigin;\n"
"    float time; float borderWidth; float cornerRadius;\n"
"    float glowInner; float glowOuter; float glowIntensity;\n"
"    int animType; float animProgress;\n"
"    float lensRingIntensity; int hasBgTex;\n"
"};\n"
"\n"
"float sdRoundBox(float2 p, float2 b, float r) {\n"
"    float2 q = abs(p)-b+r;\n"
"    return length(max(q,float2(0)))+min(max(q.x,q.y),0.0)-r;\n"
"}\n"
"\n"
"float3 hsv2rgb(float3 c) {\n"
"    float4 K = float4(1,2.0/3.0,1.0/3.0,3);\n"
"    float3 p = abs(fract(c.xxx+K.xyz)*6.0-K.www);\n"
"    return c.z*mix(K.xxx,saturate(p-K.xxx),c.y);\n"
"}\n"
"\n"
"float perimPos(float2 p) {\n"
"    return fract(atan2(-p.x, -p.y) / (2.0*M_PI_F) + 0.5);\n"
"}\n"
"\n"
"fragment float4 neonFrag(VertexOut in [[stage_in]],\n"
"                          constant U &u [[buffer(0)]],\n"
"                          texture2d<float> bgTex [[texture(0)]]) {\n"
"    float2 px = in.uv * u.resolution;\n"
"    float2 center = u.resolution * 0.5;\n"
"    float2 p = px - center;\n"
"    float2 half_c = center - float2(u.glowOuter);\n"
"    float prog = u.animProgress;\n"
"    float2 sampleP = p;\n"
"    float extraBright = 0.0;\n"
"    float2 bgDisplace = float2(0);\n"
"\n"
"    if (u.animType == 3 && prog < 0.999) {\n"
"        float2 origin = u.animOrigin - center;\n"
"        float2 toP = p - origin;\n"
"        float dist = length(toP);\n"
"        float maxR = length(u.resolution);\n"
"        float revealR = prog * maxR;\n"
"        float lensW = max(120.0, u.resolution.x * 0.25);\n"
"        float edge = dist - revealR;\n"
"        if (edge > lensW * 1.2) return float4(0);\n"
"        if (dist > 0.001) {\n"
"            float2 dir = normalize(toP);\n"
"            float decay = pow(1.0 - prog, 1.5);\n"
"            float env = exp(-edge*edge / (lensW*lensW*0.5));\n"
"            float wave = sin(saturate((edge + lensW) / (2.0*lensW)) * M_PI_F) * env * 50.0 * decay;\n"
"            bgDisplace = dir * wave;\n"
"        }\n"
"        float ringDist = abs(edge);\n"
"        float decay2 = pow(1.0 - prog, 2.0);\n"
"        extraBright = exp(-ringDist*ringDist / (lensW*lensW*0.06))\n"
"                     * u.lensRingIntensity * decay2;\n"
"    }\n"
"\n"
"    if (u.animType == 2 && prog < 0.999) {\n"
"        float2 origin = u.animOrigin - center;\n"
"        float2 toP = p - origin;\n"
"        float dist = length(toP);\n"
"        float maxR = length(u.resolution) * 1.1;\n"
"        float waveR = prog * maxR;\n"
"        float waveW = 60.0;\n"
"        if (dist > 0.001) {\n"
"            float2 dir = normalize(toP);\n"
"            float waveDist = dist - waveR;\n"
"            float decay = 1.0 - prog;\n"
"            float env1 = exp(-waveDist*waveDist / (waveW*waveW*1.5));\n"
"            float ripple1 = sin(waveDist * 0.15) * env1 * 40.0 * decay;\n"
"            float preDist = dist - (waveR + waveW * 3.0);\n"
"            float env2 = exp(-preDist*preDist / (waveW*waveW*0.5));\n"
"            float ripple2 = sin(preDist * 0.25) * env2 * 15.0 * decay;\n"
"            float tailDist = dist - max(waveR - waveW * 3.0, 0.0);\n"
"            float env3 = exp(-tailDist*tailDist / (waveW*waveW*0.8));\n"
"            float ripple3 = sin(tailDist * 0.2) * env3 * 10.0 * decay;\n"
"            bgDisplace = dir * (ripple1 + ripple2 + ripple3);\n"
"        }\n"
"    }\n"
"\n"
"    float d = sdRoundBox(sampleP, half_c, u.cornerRadius);\n"
"    float angle = atan2(sampleP.y, sampleP.x);\n"
"    float hue = fract(angle / (2.0*M_PI_F) + 0.5 + u.time);\n"
"    float3 color = hsv2rgb(float3(hue, 0.75, 1.0));\n"
"\n"
"    float halfBW = u.borderWidth * 0.5;\n"
"    float borderA = 1.0 - smoothstep(-0.5, 1.0, abs(d) - halfBW);\n"
"    float glowDist = max(abs(d) - halfBW, 0.0);\n"
"    float sigma = (d < 0.0) ? (u.glowInner*0.38) : (u.glowOuter*0.38);\n"
"    float glowA = exp(-(glowDist*glowDist) / max(2.0*sigma*sigma, 0.001)) * u.glowIntensity;\n"
"    float baseAlpha = max(borderA, glowA);\n"
"    float nA = saturate(baseAlpha + extraBright);\n"
"    float3 neonColor = mix(color, float3(1.0), saturate(extraBright));\n"
"    float nearBorder = saturate(baseAlpha * 3.0);\n"
"\n"
"    float mask = 1.0;\n"
"\n"
"    if (u.animType == 1) {\n"
"        mask = prog;\n"
"    }\n"
"    else if (u.animType == 2) {\n"
"        float2 origin = u.animOrigin - center;\n"
"        float dist = length(p - origin);\n"
"        float maxR = length(u.resolution) * 1.1;\n"
"        float waveR = prog * maxR;\n"
"        float waveW = 50.0;\n"
"        mask = 1.0 - smoothstep(waveR - waveW * 0.3, waveR + waveW, dist);\n"
"        float ring1 = exp(-pow(dist - waveR, 2.0) / (waveW*waveW*0.5)) * 2.0;\n"
"        float preR = waveR + waveW * 1.5;\n"
"        float ring2 = exp(-pow(dist - preR, 2.0) / (waveW*waveW*0.3)) * 0.6;\n"
"        float tailR = max(waveR - waveW * 2.0, 0.0);\n"
"        float ring3 = exp(-pow(dist - tailR, 2.0) / (waveW*waveW*0.8)) * 0.3;\n"
"        float rings = ring1 + ring2 + ring3;\n"
"        nA = saturate(nA * mask + rings * nearBorder);\n"
"        neonColor = mix(neonColor, float3(1.0), saturate(rings * nearBorder * 0.5));\n"
"        mask = 1.0;\n"
"    }\n"
"    else if (u.animType == 3) {\n"
"        float2 origin = u.animOrigin - center;\n"
"        float dist = length(p - origin);\n"
"        float maxR = length(u.resolution);\n"
"        float revealR = prog * maxR;\n"
"        float lensW = max(120.0, u.resolution.x * 0.25);\n"
"        mask = 1.0 - smoothstep(revealR - lensW * 0.2, revealR + lensW, dist);\n"
"        float waveFrontDist = abs(dist - revealR);\n"
"        float waveBright = exp(-waveFrontDist*waveFrontDist / (lensW*lensW*0.15))\n"
"                          * nearBorder * 2.5 * pow(1.0 - prog, 1.5);\n"
"        nA = saturate(nA * mask + waveBright);\n"
"        neonColor = mix(neonColor, float3(1.0), saturate(waveBright * 0.6));\n"
"        mask = 1.0;\n"
"    }\n"
"    else if (u.animType == 4) {\n"
"        float pos = perimPos(sampleP);\n"
"        float head = prog;\n"
"        float behind = fract(head - pos);\n"
"        float trailMask = 1.0 - smoothstep(head, head + 0.02, behind);\n"
"        float headDiff = pos - head;\n"
"        if (headDiff > 0.5) headDiff -= 1.0;\n"
"        if (headDiff < -0.5) headDiff += 1.0;\n"
"        float headGlow = exp(-headDiff*headDiff / 0.0002) * 3.0 * nearBorder;\n"
"        headGlow *= 1.0 - smoothstep(0.85, 0.98, prog);\n"
"        float freshness = 1.0 - behind * 0.2;\n"
"        nA = saturate(nA * trailMask * freshness + headGlow);\n"
"        neonColor = mix(neonColor, float3(1.0), saturate(headGlow * 0.5));\n"
"        mask = 1.0;\n"
"    }\n"
"\n"
"    nA *= mask;\n"
"\n"
"    float dispLen = length(bgDisplace);\n"
"    if (u.hasBgTex != 0 && dispLen > 0.3) {\n"
"        constexpr sampler s(filter::linear, address::clamp_to_edge);\n"
"        float2 contentOrigin = float2(u.glowOuter);\n"
"        float2 contentSize = u.resolution - 2.0 * contentOrigin;\n"
"        float2 bgUV = (px + bgDisplace - contentOrigin) / contentSize;\n"
"        bgUV = saturate(bgUV);\n"
"        float4 bg = bgTex.sample(s, bgUV);\n"
"        float dM = saturate(dispLen * 0.03);\n"
"        float combinedA = dM + nA - dM * nA;\n"
"        float3 premulRGB = bg.rgb * dM * (1.0 - nA) + neonColor * nA;\n"
"        if (combinedA < 0.001) return float4(0);\n"
"        return float4(premulRGB, combinedA);\n"
"    }\n"
"\n"
"    if (nA < 0.001) return float4(0);\n"
"    return float4(neonColor * nA, nA);\n"
"}\n";

typedef struct {
    simd_float2 resolution;
    simd_float2 animOrigin;
    float time;
    float borderWidth;
    float cornerRadius;
    float glowInner;
    float glowOuter;
    float glowIntensity;
    int32_t animType;
    float animProgress;
    float lensRingIntensity;
    int32_t hasBgTex;
} NeonUniforms;

@interface NGNeonGlowView () <MTKViewDelegate>
@end

@implementation NGNeonGlowView {
    MTKView *_metalView;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _queue;
    id<MTLRenderPipelineState> _pipeline;
    id<MTLTexture> _bgTexture;
    id<MTLTexture> _dummyTexture;
    CFTimeInterval _lastTime;
    float _flowTime;
    BOOL _flowing;
    int32_t _animType;
    float _animProgress;
    simd_float2 _animOrigin;
    CFTimeInterval _animStartTime;
    NSTimeInterval _animDuration;
    BOOL _animForward;
    void (^_animCompletion)(void);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
        [self setupMetal];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultConfig];
        [self setupMetal];
    }
    return self;
}

- (void)defaultConfig {
    _neonBorderWidth = 3.0;
    _neonCornerRadius = 20.0;
    _matchesScreenCornerRadius = NO;
    _glowInnerSpread = 25.0;
    _glowOuterSpread = 10.0;
    _glowIntensity = 0.8;
    _lensRingIntensity = 0.3;
    _flowSpeed = 0.15;
    _animationSpeedMultiplier = 1.0;
    _flowing = NO;
    _animType = 0;
    _animProgress = 1.0;
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = NO;
}

- (void)setupMetal {
    _device = MTLCreateSystemDefaultDevice();
    if (!_device) {
        return;
    }

    _metalView = [[MTKView alloc] initWithFrame:self.bounds device:_device];
    _metalView.delegate = self;
    _metalView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    _metalView.opaque = NO;
    _metalView.layer.opaque = NO;
    _metalView.backgroundColor = UIColor.clearColor;
    _metalView.preferredFramesPerSecond = 60;
    _metalView.paused = YES;
    _metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_metalView];

    _queue = [_device newCommandQueue];

    NSError *error = nil;
    id<MTLLibrary> library = [_device newLibraryWithSource:kShaderSource options:nil error:&error];
    if (!library) {
        NSLog(@"Neon shader error: %@", error);
        return;
    }

    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.vertexFunction = [library newFunctionWithName:@"neonVtx"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"neonFrag"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.colorAttachments[0].blendingEnabled = YES;
    descriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
    descriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    descriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
    descriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;

    _pipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!_pipeline) {
        NSLog(@"Neon pipeline error: %@", error);
    }

    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                                  width:1
                                                                                                 height:1
                                                                                              mipmapped:NO];
    _dummyTexture = [_device newTextureWithDescriptor:textureDescriptor];
}

#pragma mark - Properties

- (void)setMatchesScreenCornerRadius:(BOOL)matchesScreenCornerRadius {
    _matchesScreenCornerRadius = matchesScreenCornerRadius;
    if (matchesScreenCornerRadius) {
        _neonCornerRadius = [NGScreenGeometry displayCornerRadiusForCurrentDevice];
    }
}

- (void)setNeonCornerRadius:(CGFloat)neonCornerRadius {
    _neonCornerRadius = neonCornerRadius;
    _matchesScreenCornerRadius = NO;
}

#pragma mark - Passthrough

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

#pragma mark - Distortion

- (void)prepareDistortionWithView:(UIView *)sourceView {
    if (!_device || !sourceView || sourceView.bounds.size.width < 1 || sourceView.bounds.size.height < 1) {
        return;
    }

    CGFloat scale = UIScreen.mainScreen.scale;
    UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, YES, scale);
    [sourceView drawViewHierarchyInRect:sourceView.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!image) {
        return;
    }

    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:_device];
    NSError *error = nil;
    _bgTexture = [loader newTextureWithCGImage:image.CGImage
                                      options:@{ MTKTextureLoaderOptionSRGB: @NO }
                                        error:&error];
    if (error) {
        NSLog(@"BG texture error: %@", error);
    }
}

- (void)clearDistortionSource {
    _bgTexture = nil;
}

#pragma mark - Flow

- (void)startFlowing {
    _flowing = YES;
    [self ensureRunning];
}

- (void)stopFlowing {
    _flowing = NO;
    [self checkPause];
}

#pragma mark - Show / Dismiss

- (void)showWithAnimation:(NGNeonGlowAnimation)animation
                 duration:(NSTimeInterval)duration
                fromPoint:(CGPoint)point
               completion:(void (^)(void))completion {
    self.hidden = NO;
    _lastTime = 0;
    _animType = (int32_t)animation;
    _animProgress = 0.0;
    _animForward = YES;
    _animDuration = MAX(duration / MAX(self.animationSpeedMultiplier, 0.1), 0.01);
    _animStartTime = CACurrentMediaTime();
    _animCompletion = [completion copy];
    _animOrigin = simd_make_float2(point.x, point.y);
    [_metalView draw];
    [self ensureRunning];
}

- (void)dismissWithAnimation:(NGNeonGlowAnimation)animation
                    duration:(NSTimeInterval)duration
                  completion:(void (^)(void))completion {
    _animType = (int32_t)animation;
    _animProgress = 1.0;
    _animForward = NO;
    _animDuration = MAX(duration / MAX(self.animationSpeedMultiplier, 0.1), 0.01);
    _animStartTime = CACurrentMediaTime();
    _animCompletion = [completion copy];
    [self ensureRunning];
}

#pragma mark - Private

- (void)ensureRunning {
    _metalView.paused = NO;
}

- (void)checkPause {
    if (!_flowing && _animType == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self->_flowing && self->_animType == 0) {
                self->_metalView.paused = YES;
            }
        });
    }
}

- (void)updateAnimProgress {
    if (_animType == 0) {
        return;
    }
    CFTimeInterval elapsed = CACurrentMediaTime() - _animStartTime;
    float t = MIN(elapsed / _animDuration, 1.0);
    t = t * t * (3.0 - 2.0 * t);
    _animProgress = _animForward ? t : (1.0 - t);
    if (elapsed >= _animDuration) {
        _animProgress = _animForward ? 1.0 : 0.0;
        if (!_animForward) {
            self.hidden = YES;
        }
        _animType = 0;
        void (^completion)(void) = _animCompletion;
        _animCompletion = nil;
        [self checkPause];
        if (completion) {
            completion();
        }
    }
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

- (void)drawInMTKView:(MTKView *)view {
    if (!_pipeline) {
        return;
    }

    CFTimeInterval now = CACurrentMediaTime();
    if (_flowing && _lastTime > 0) {
        _flowTime += (now - _lastTime) * self.flowSpeed;
        if (_flowTime > 1.0) {
            _flowTime -= 1.0;
        }
    }
    _lastTime = now;
    [self updateAnimProgress];

    CGFloat scale = view.contentScaleFactor;
    CGSize drawableSize = view.drawableSize;
    BOOL hasBackground = (_bgTexture != nil);
    NeonUniforms uniforms = {
        .resolution = simd_make_float2(drawableSize.width, drawableSize.height),
        .animOrigin = simd_make_float2(_animOrigin.x * drawableSize.width, _animOrigin.y * drawableSize.height),
        .time = _flowTime,
        .borderWidth = (float)(self.neonBorderWidth * scale),
        .cornerRadius = (float)(self.neonCornerRadius * scale),
        .glowInner = (float)(self.glowInnerSpread * scale),
        .glowOuter = (float)(self.glowOuterSpread * scale),
        .glowIntensity = (float)self.glowIntensity,
        .animType = _animType,
        .animProgress = _animProgress,
        .lensRingIntensity = (float)self.lensRingIntensity,
        .hasBgTex = hasBackground ? 1 : 0
    };

    id<MTLCommandBuffer> commandBuffer = [_queue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (!renderPassDescriptor || !commandBuffer) {
        return;
    }

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [encoder setRenderPipelineState:_pipeline];
    [encoder setFragmentBytes:&uniforms length:sizeof(uniforms) atIndex:0];
    [encoder setFragmentTexture:(hasBackground ? _bgTexture : _dummyTexture) atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [encoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

@end
