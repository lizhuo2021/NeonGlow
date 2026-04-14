//
//  SwiftNeonGlowShowcaseViewController.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import NeonGlowKit
import UIKit

private enum SwiftControlTag: Int {
    case showDuration = 100
    case dismissDuration
    case borderWidth
    case cornerRadius
    case glowInner
    case glowOuter
    case glowIntensity
    case lensRingIntensity
    case flowSpeed
    case animationSpeed
}

final class SwiftNeonGlowShowcaseViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let previewContainer = UIView()
    private let previewBackgroundView = GradientBackdropView()
    private let previewMaskView = UIView()
    private let previewTitleLabel = UILabel()
    private let previewDescLabel = UILabel()
    private let tipLabel = UILabel()
    private let touchIndicatorView = UIView()
    private let neonView = NeonGlowView()

    private let controlPanelView = UIView()
    private let controlStackView = UIStackView()

    private let showAnimationRow = MenuControlRowView(title: "Show Animation")
    private let dismissAnimationRow = MenuControlRowView(title: "Dismiss Animation")
    private let matchCornersRow = ToggleControlRowView(title: "Match Screen Corner Radius")
    private let distortionRow = ToggleControlRowView(title: "Use Background Distortion")
    private let touchIndicatorRow = ToggleControlRowView(title: "Show Touch Indicator")

    private lazy var showDurationRow = makeSliderRow(title: "Show Duration", tag: .showDuration, min: 0.15, max: 3.0)
    private lazy var dismissDurationRow = makeSliderRow(title: "Dismiss Duration", tag: .dismissDuration, min: 0.10, max: 2.0)
    private lazy var borderWidthRow = makeSliderRow(title: "Border Width", tag: .borderWidth, min: 1.0, max: 12.0)
    private lazy var cornerRadiusRow = makeSliderRow(title: "Corner Radius", tag: .cornerRadius, min: 0.0, max: 80.0)
    private lazy var glowInnerRow = makeSliderRow(title: "Glow Inner Spread", tag: .glowInner, min: 0.0, max: 80.0)
    private lazy var glowOuterRow = makeSliderRow(title: "Glow Outer Spread", tag: .glowOuter, min: 0.0, max: 36.0)
    private lazy var glowIntensityRow = makeSliderRow(title: "Glow Intensity", tag: .glowIntensity, min: 0.0, max: 1.5)
    private lazy var lensRingRow = makeSliderRow(title: "Lens Ring Intensity", tag: .lensRingIntensity, min: 0.0, max: 1.2)
    private lazy var flowSpeedRow = makeSliderRow(title: "Flow Speed", tag: .flowSpeed, min: 0.0, max: 0.8)
    private lazy var animationSpeedRow = makeSliderRow(title: "Animation Speed Multiplier", tag: .animationSpeed, min: 0.2, max: 3.0)

    private let triggerCenterButton = UIButton(type: .system)
    private let randomBurstButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)
    private let flowButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)

    private var neonTopConstraint: NSLayoutConstraint?
    private var neonLeadingConstraint: NSLayoutConstraint?
    private var neonTrailingConstraint: NSLayoutConstraint?
    private var neonBottomConstraint: NSLayoutConstraint?

    private var isFlowing = true
    private var showAnimation: NeonGlowAnimation = .wave
    private var dismissAnimation: NeonGlowAnimation = .fade
    private var showDuration: Double = 1.2
    private var dismissDuration: Double = 0.35
    private var distortionEnabled = true
    private var touchIndicatorEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        resetControlsToDefaults()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFlowing {
            neonView.startFlowing()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        neonView.stopFlowing()
        neonView.clearDistortionSource()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1.0)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        contentView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "NeonGlow"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 38, weight: .black)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Swift 版现在提供完整参数控制台。双击卡片或用下方按钮触发，快速对比不同动画与 shader 参数。"
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.72)
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.numberOfLines = 0

        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        previewContainer.layer.cornerRadius = 28.0
        previewContainer.layer.masksToBounds = true

        previewBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        previewMaskView.translatesAutoresizingMaskIntoConstraints = false
        previewMaskView.backgroundColor = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 0.34)

        previewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        previewTitleLabel.textColor = .white
        previewTitleLabel.font = .systemFont(ofSize: 28, weight: .semibold)

        previewDescLabel.translatesAutoresizingMaskIntoConstraints = false
        previewDescLabel.text = "Double tap anywhere on the card. The burst starts from the tap point, using the same Metal shader path as the Objective-C version."
        previewDescLabel.textColor = UIColor(white: 1.0, alpha: 0.88)
        previewDescLabel.font = .systemFont(ofSize: 15, weight: .medium)
        previewDescLabel.numberOfLines = 0

        touchIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        touchIndicatorView.backgroundColor = .clear
        touchIndicatorView.layer.cornerRadius = 14
        touchIndicatorView.layer.borderWidth = 2
        touchIndicatorView.layer.borderColor = UIColor(red: 71.0 / 255.0, green: 216.0 / 255.0, blue: 1.0, alpha: 0.95).cgColor
        touchIndicatorView.isHidden = true

        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.text = "Repo includes both Swift and Objective-C demo targets, and both now expose a full control panel."
        tipLabel.textColor = UIColor(white: 1.0, alpha: 0.58)
        tipLabel.font = .systemFont(ofSize: 13, weight: .regular)
        tipLabel.numberOfLines = 0

        neonView.translatesAutoresizingMaskIntoConstraints = false

        controlPanelView.translatesAutoresizingMaskIntoConstraints = false
        controlPanelView.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        controlPanelView.layer.cornerRadius = 28
        controlPanelView.layer.borderWidth = 1
        controlPanelView.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor

        controlStackView.translatesAutoresizingMaskIntoConstraints = false
        controlStackView.axis = .vertical
        controlStackView.spacing = 16

        style(button: triggerCenterButton, title: "Trigger Center")
        style(button: randomBurstButton, title: "Random Burst")
        style(button: dismissButton, title: "Dismiss")
        style(button: flowButton, title: "Pause Flow")
        style(button: resetButton, title: "Reset")

        [showAnimationRow, dismissAnimationRow, matchCornersRow, distortionRow, touchIndicatorRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(previewContainer)
        contentView.addSubview(tipLabel)
        contentView.addSubview(controlPanelView)
        controlPanelView.addSubview(controlStackView)
        contentView.addSubview(neonView)

        previewContainer.addSubview(previewBackgroundView)
        previewContainer.addSubview(previewMaskView)
        previewContainer.addSubview(previewTitleLabel)
        previewContainer.addSubview(previewDescLabel)
        previewContainer.addSubview(touchIndicatorView)

        addControlSection(title: "Animation")
        [showAnimationRow, dismissAnimationRow, showDurationRow, dismissDurationRow].forEach { controlStackView.addArrangedSubview($0) }

        addControlSection(title: "Appearance")
        [borderWidthRow, cornerRadiusRow, glowInnerRow, glowOuterRow, glowIntensityRow, lensRingRow].forEach { controlStackView.addArrangedSubview($0) }

        addControlSection(title: "Behavior")
        [flowSpeedRow, animationSpeedRow, matchCornersRow, distortionRow, touchIndicatorRow].forEach { controlStackView.addArrangedSubview($0) }

        addControlSection(title: "Actions")
        controlStackView.addArrangedSubview(makeActionRows())
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            previewContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            previewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            previewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            previewContainer.heightAnchor.constraint(equalToConstant: 360),

            previewBackgroundView.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewBackgroundView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewBackgroundView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewBackgroundView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),

            previewMaskView.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewMaskView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewMaskView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewMaskView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),

            previewTitleLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 24),
            previewTitleLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -24),
            previewTitleLabel.bottomAnchor.constraint(equalTo: previewDescLabel.topAnchor, constant: -12),

            previewDescLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 24),
            previewDescLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -24),
            previewDescLabel.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -30),

            touchIndicatorView.widthAnchor.constraint(equalToConstant: 28),
            touchIndicatorView.heightAnchor.constraint(equalToConstant: 28),

            tipLabel.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 24),
            tipLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            tipLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),

            controlPanelView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 20),
            controlPanelView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            controlPanelView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            controlPanelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            controlStackView.topAnchor.constraint(equalTo: controlPanelView.topAnchor, constant: 20),
            controlStackView.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: 18),
            controlStackView.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -18),
            controlStackView.bottomAnchor.constraint(equalTo: controlPanelView.bottomAnchor, constant: -20)
        ])

        neonTopConstraint = neonView.topAnchor.constraint(equalTo: previewContainer.topAnchor)
        neonLeadingConstraint = neonView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor)
        neonTrailingConstraint = neonView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor)
        neonBottomConstraint = neonView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor)
        NSLayoutConstraint.activate([
            neonTopConstraint,
            neonLeadingConstraint,
            neonTrailingConstraint,
            neonBottomConstraint
        ].compactMap { $0 })
    }

    private func setupActions() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handlePreviewDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        previewContainer.addGestureRecognizer(doubleTap)

        triggerCenterButton.addTarget(self, action: #selector(handleTriggerCenter), for: .touchUpInside)
        randomBurstButton.addTarget(self, action: #selector(handleRandomBurst), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        flowButton.addTarget(self, action: #selector(handleFlowToggle), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(handleReset), for: .touchUpInside)

        matchCornersRow.toggleSwitch.addTarget(self, action: #selector(handleSwitchChanged(_:)), for: .valueChanged)
        distortionRow.toggleSwitch.addTarget(self, action: #selector(handleSwitchChanged(_:)), for: .valueChanged)
        touchIndicatorRow.toggleSwitch.addTarget(self, action: #selector(handleSwitchChanged(_:)), for: .valueChanged)
    }

    private func resetControlsToDefaults() {
        let configuration = NeonGlowConfiguration.showcaseStyle()
        showAnimation = .wave
        dismissAnimation = .fade
        showDuration = 1.2
        dismissDuration = 0.35
        isFlowing = true
        distortionEnabled = true
        touchIndicatorEnabled = true

        showDurationRow.slider.value = Float(showDuration)
        dismissDurationRow.slider.value = Float(dismissDuration)
        borderWidthRow.slider.value = Float(configuration.neonBorderWidth)
        cornerRadiusRow.slider.value = Float(configuration.neonCornerRadius)
        glowInnerRow.slider.value = Float(configuration.glowInnerSpread)
        glowOuterRow.slider.value = Float(configuration.glowOuterSpread)
        glowIntensityRow.slider.value = Float(configuration.glowIntensity)
        lensRingRow.slider.value = Float(configuration.lensRingIntensity)
        flowSpeedRow.slider.value = Float(configuration.flowSpeed)
        animationSpeedRow.slider.value = Float(configuration.animationSpeedMultiplier)

        matchCornersRow.toggleSwitch.isOn = configuration.matchesScreenCornerRadius
        distortionRow.toggleSwitch.isOn = distortionEnabled
        touchIndicatorRow.toggleSwitch.isOn = touchIndicatorEnabled

        applyCurrentConfiguration()
    }

    private func applyCurrentConfiguration() {
        neonView.neonBorderWidth = CGFloat(borderWidthRow.slider.value)
        neonView.glowInnerSpread = CGFloat(glowInnerRow.slider.value)
        neonView.glowOuterSpread = CGFloat(glowOuterRow.slider.value)
        neonView.glowIntensity = CGFloat(glowIntensityRow.slider.value)
        neonView.lensRingIntensity = CGFloat(lensRingRow.slider.value)
        neonView.flowSpeed = CGFloat(flowSpeedRow.slider.value)
        neonView.animationSpeedMultiplier = CGFloat(animationSpeedRow.slider.value)

        if matchCornersRow.toggleSwitch.isOn {
            neonView.matchesScreenCornerRadius = true
        } else {
            neonView.matchesScreenCornerRadius = false
            neonView.neonCornerRadius = CGFloat(cornerRadiusRow.slider.value)
        }

        let resolvedCornerRadius = neonView.neonCornerRadius
        previewContainer.layer.cornerRadius = resolvedCornerRadius

        let outerGlow = neonView.glowOuterSpread
        neonTopConstraint?.constant = -outerGlow
        neonLeadingConstraint?.constant = -outerGlow
        neonTrailingConstraint?.constant = outerGlow
        neonBottomConstraint?.constant = outerGlow

        showDuration = Double(showDurationRow.slider.value)
        dismissDuration = Double(dismissDurationRow.slider.value)
        distortionEnabled = distortionRow.toggleSwitch.isOn
        touchIndicatorEnabled = touchIndicatorRow.toggleSwitch.isOn

        showDurationRow.setValueText(format(showDuration, digits: 2))
        dismissDurationRow.setValueText(format(dismissDuration, digits: 2))
        borderWidthRow.setValueText(format(borderWidthRow.slider.value, digits: 1))
        cornerRadiusRow.setValueText(matchCornersRow.toggleSwitch.isOn ? "Auto \(format(resolvedCornerRadius, digits: 1))" : format(cornerRadiusRow.slider.value, digits: 1))
        glowInnerRow.setValueText(format(glowInnerRow.slider.value, digits: 1))
        glowOuterRow.setValueText(format(glowOuterRow.slider.value, digits: 1))
        glowIntensityRow.setValueText(format(glowIntensityRow.slider.value, digits: 2))
        lensRingRow.setValueText(format(lensRingRow.slider.value, digits: 2))
        flowSpeedRow.setValueText(format(flowSpeedRow.slider.value, digits: 2))
        animationSpeedRow.setValueText(format(animationSpeedRow.slider.value, digits: 2))

        showAnimationRow.setSelectionTitle(showAnimation.title)
        dismissAnimationRow.setSelectionTitle(dismissAnimation.title)
        previewTitleLabel.text = "NEON \(showAnimation.title.uppercased())"
        flowButton.configuration?.title = isFlowing ? "Pause Flow" : "Resume Flow"

        rebuildAnimationMenus()
        view.layoutIfNeeded()
    }

    private func rebuildAnimationMenus() {
        showAnimationRow.selectionButton.menu = animationMenu(current: showAnimation) { [weak self] animation in
            self?.showAnimation = animation
            self?.applyCurrentConfiguration()
        }
        dismissAnimationRow.selectionButton.menu = animationMenu(current: dismissAnimation) { [weak self] animation in
            self?.dismissAnimation = animation
            self?.applyCurrentConfiguration()
        }
    }

    private func animationMenu(current: NeonGlowAnimation, handler: @escaping (NeonGlowAnimation) -> Void) -> UIMenu {
        let actions = NeonGlowAnimation.allCases.map { animation in
            UIAction(title: animation.title, state: animation == current ? .on : .off) { _ in
                handler(animation)
            }
        }
        return UIMenu(options: .displayInline, children: actions)
    }

    private func addControlSection(title: String) {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        controlStackView.addArrangedSubview(label)
    }

    private func makeSliderRow(title: String, tag: SwiftControlTag, min: Float, max: Float) -> SliderControlRowView {
        let row = SliderControlRowView(title: title)
        row.slider.minimumValue = min
        row.slider.maximumValue = max
        row.slider.tag = tag.rawValue
        row.slider.addTarget(self, action: #selector(handleSliderChanged(_:)), for: .valueChanged)
        return row
    }

    private func makeActionRows() -> UIView {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 12

        let firstRow = UIStackView(arrangedSubviews: [triggerCenterButton, randomBurstButton, dismissButton])
        firstRow.axis = .horizontal
        firstRow.spacing = 10
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView(arrangedSubviews: [flowButton, resetButton])
        secondRow.axis = .horizontal
        secondRow.spacing = 10
        secondRow.distribution = .fillEqually

        [triggerCenterButton, randomBurstButton, dismissButton, flowButton, resetButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }

        verticalStack.addArrangedSubview(firstRow)
        verticalStack.addArrangedSubview(secondRow)
        return verticalStack
    }

    private func style(button: UIButton, title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = UIColor(white: 1.0, alpha: 0.12)
        configuration.cornerStyle = .large
        button.configuration = configuration
    }

    @objc
    private func handlePreviewDoubleTap(_ gesture: UITapGestureRecognizer) {
        triggerNeon(at: gesture.location(in: previewContainer))
    }

    @objc
    private func handleTriggerCenter() {
        let point = CGPoint(x: previewContainer.bounds.midX, y: previewContainer.bounds.midY)
        triggerNeon(at: point)
    }

    @objc
    private func handleRandomBurst() {
        let inset: CGFloat = 30
        let width = max(previewContainer.bounds.width - inset * 2, 1)
        let height = max(previewContainer.bounds.height - inset * 2, 1)
        let point = CGPoint(
            x: inset + CGFloat.random(in: 0 ... width),
            y: inset + CGFloat.random(in: 0 ... height)
        )
        triggerNeon(at: point)
    }

    @objc
    private func handleDismiss() {
        neonView.dismiss(animation: dismissAnimation, duration: dismissDuration) { [weak self] in
            guard let self else { return }
            self.neonView.clearDistortionSource()
            if self.isFlowing {
                self.neonView.startFlowing()
            } else {
                self.neonView.stopFlowing()
            }
        }
    }

    @objc
    private func handleFlowToggle() {
        isFlowing.toggle()
        if isFlowing {
            neonView.startFlowing()
        } else {
            neonView.stopFlowing()
        }
        applyCurrentConfiguration()
    }

    @objc
    private func handleReset() {
        resetControlsToDefaults()
    }

    @objc
    private func handleSliderChanged(_ sender: UISlider) {
        if sender.tag == SwiftControlTag.cornerRadius.rawValue, matchCornersRow.toggleSwitch.isOn {
            matchCornersRow.toggleSwitch.isOn = false
        }
        applyCurrentConfiguration()
    }

    @objc
    private func handleSwitchChanged(_ sender: UISwitch) {
        applyCurrentConfiguration()
    }

    private func triggerNeon(at point: CGPoint) {
        let neonSize = neonView.bounds.size
        guard neonSize.width >= 1, neonSize.height >= 1 else { return }

        let outerGlow = neonView.glowOuterSpread
        let normalizedPoint = CGPoint(
            x: (point.x + outerGlow) / neonSize.width,
            y: (point.y + outerGlow) / neonSize.height
        )

        if touchIndicatorEnabled {
            showTouchIndicator(at: point)
        }

        neonView.isHidden = true
        neonView.stopFlowing()
        neonView.clearDistortionSource()
        if distortionEnabled {
            neonView.prepareDistortion(with: previewContainer)
        }
        neonView.show(animation: showAnimation, duration: showDuration, from: normalizedPoint, completion: nil)
        if isFlowing {
            neonView.startFlowing()
        }
    }

    private func showTouchIndicator(at point: CGPoint) {
        touchIndicatorView.isHidden = false
        touchIndicatorView.alpha = 1.0
        touchIndicatorView.transform = .identity
        touchIndicatorView.center = point

        UIView.animate(withDuration: 0.65, delay: 0, options: .curveEaseOut) {
            self.touchIndicatorView.alpha = 0.0
            self.touchIndicatorView.transform = CGAffineTransform(scaleX: 2.1, y: 2.1)
        } completion: { _ in
            self.touchIndicatorView.isHidden = true
            self.touchIndicatorView.transform = .identity
        }
    }

    private func format(_ value: Float, digits: Int) -> String {
        String(format: "%.\(digits)f", value)
    }

    private func format(_ value: Double, digits: Int) -> String {
        String(format: "%.\(digits)f", value)
    }

    private func format(_ value: CGFloat, digits: Int) -> String {
        String(format: "%.\(digits)f", value)
    }
}

private final class SliderControlRowView: UIView {
    let slider = UISlider()

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        valueLabel.textColor = UIColor(white: 1.0, alpha: 0.56)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        valueLabel.textAlignment = .right

        slider.minimumTrackTintColor = UIColor(red: 0.27, green: 0.93, blue: 1.0, alpha: 1.0)
        slider.maximumTrackTintColor = UIColor(white: 1.0, alpha: 0.14)

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        headerStack.axis = .horizontal

        let stack = UIStackView(arrangedSubviews: [headerStack, slider])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setValueText(_ value: String) {
        valueLabel.text = value
    }
}

private final class ToggleControlRowView: UIView {
    let toggleSwitch = UISwitch()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        toggleSwitch.onTintColor = UIColor(red: 0.27, green: 0.93, blue: 1.0, alpha: 1.0)

        let stack = UIStackView(arrangedSubviews: [titleLabel, toggleSwitch])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }
}

private final class MenuControlRowView: UIView {
    let selectionButton = UIButton(type: .system)

    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        var configuration = UIButton.Configuration.tinted()
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = UIColor(white: 1.0, alpha: 0.12)
        configuration.image = UIImage(systemName: "chevron.up.chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        selectionButton.configuration = configuration
        selectionButton.showsMenuAsPrimaryAction = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, selectionButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        selectionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 156).isActive = true

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setSelectionTitle(_ title: String) {
        selectionButton.configuration?.title = title
    }
}

private final class GradientBackdropView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private let topOrb = UIView()
    private let bottomOrb = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupOrbs()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        setupOrbs()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topOrb.frame = CGRect(x: -40, y: 30, width: 180, height: 180)
        bottomOrb.frame = CGRect(x: bounds.width - 170, y: bounds.height - 210, width: 210, height: 210)
    }

    private func setupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = [
            UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 1.0).cgColor,
            UIColor(red: 0.11, green: 0.16, blue: 0.28, alpha: 1.0).cgColor,
            UIColor(red: 0.17, green: 0.12, blue: 0.24, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    }

    private func setupOrbs() {
        topOrb.backgroundColor = UIColor(red: 0.16, green: 0.90, blue: 1.0, alpha: 0.22)
        topOrb.layer.cornerRadius = 90
        topOrb.layer.shadowColor = topOrb.backgroundColor?.cgColor
        topOrb.layer.shadowOpacity = 1.0
        topOrb.layer.shadowRadius = 42
        topOrb.layer.shadowOffset = .zero

        bottomOrb.backgroundColor = UIColor(red: 1.0, green: 0.34, blue: 0.74, alpha: 0.18)
        bottomOrb.layer.cornerRadius = 105
        bottomOrb.layer.shadowColor = bottomOrb.backgroundColor?.cgColor
        bottomOrb.layer.shadowOpacity = 1.0
        bottomOrb.layer.shadowRadius = 54
        bottomOrb.layer.shadowOffset = .zero

        addSubview(topOrb)
        addSubview(bottomOrb)
    }
}
