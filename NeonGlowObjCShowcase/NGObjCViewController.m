//
//  NGObjCViewController.m
//  NeonGlowObjC
//
//  Created by 李琢 on 2026/04/14.
//

#import "NGObjCViewController.h"
#import "NGNeonGlowView.h"

typedef NS_ENUM(NSInteger, NGObjCSliderTag) {
    NGObjCSliderTagShowDuration = 200,
    NGObjCSliderTagDismissDuration,
    NGObjCSliderTagBorderWidth,
    NGObjCSliderTagCornerRadius,
    NGObjCSliderTagGlowInner,
    NGObjCSliderTagGlowOuter,
    NGObjCSliderTagGlowIntensity,
    NGObjCSliderTagLensRing,
    NGObjCSliderTagFlowSpeed,
    NGObjCSliderTagAnimationSpeed,
};

@interface NGObjCGradientBackdropView : UIView
@end

@implementation NGObjCGradientBackdropView {
    UIView *_topOrb;
    UIView *_bottomOrb;
}

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGradient];
        [self setupOrbs];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _topOrb.frame = CGRectMake(-40, 30, 180, 180);
    _bottomOrb.frame = CGRectMake(CGRectGetWidth(self.bounds) - 170, CGRectGetHeight(self.bounds) - 210, 210, 210);
}

- (void)setupGradient {
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.06 green:0.10 blue:0.20 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.11 green:0.16 blue:0.28 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.17 green:0.12 blue:0.24 alpha:1.0].CGColor,
    ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
}

- (void)setupOrbs {
    _topOrb = [UIView new];
    _topOrb.backgroundColor = [UIColor colorWithRed:0.16 green:0.90 blue:1.0 alpha:0.22];
    _topOrb.layer.cornerRadius = 90;
    _topOrb.layer.shadowColor = _topOrb.backgroundColor.CGColor;
    _topOrb.layer.shadowOpacity = 1.0;
    _topOrb.layer.shadowRadius = 42;
    _topOrb.layer.shadowOffset = CGSizeZero;

    _bottomOrb = [UIView new];
    _bottomOrb.backgroundColor = [UIColor colorWithRed:1.0 green:0.34 blue:0.74 alpha:0.18];
    _bottomOrb.layer.cornerRadius = 105;
    _bottomOrb.layer.shadowColor = _bottomOrb.backgroundColor.CGColor;
    _bottomOrb.layer.shadowOpacity = 1.0;
    _bottomOrb.layer.shadowRadius = 54;
    _bottomOrb.layer.shadowOffset = CGSizeZero;

    [self addSubview:_topOrb];
    [self addSubview:_bottomOrb];
}

@end

@interface NGObjCSliderRowView : UIView

@property (nonatomic, strong, readonly) UISlider *slider;
@property (nonatomic, strong, readonly) UILabel *valueLabel;

- (instancetype)initWithTitle:(NSString *)title;
- (void)setValueText:(NSString *)text;

@end

@implementation NGObjCSliderRowView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = title;
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];

        _valueLabel = [UILabel new];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _valueLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.56];
        _valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium];
        _valueLabel.textAlignment = NSTextAlignmentRight;

        UIStackView *headerStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, _valueLabel]];
        headerStack.translatesAutoresizingMaskIntoConstraints = NO;
        headerStack.axis = UILayoutConstraintAxisHorizontal;

        _slider = [UISlider new];
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0.27 green:0.93 blue:1.0 alpha:1.0];
        _slider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.14];

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[headerStack, _slider]];
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 8;

        [self addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.topAnchor constraintEqualToAnchor:self.topAnchor],
            [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)setValueText:(NSString *)text {
    self.valueLabel.text = text;
}

@end

@interface NGObjCToggleRowView : UIView

@property (nonatomic, strong, readonly) UISwitch *toggleSwitch;

- (instancetype)initWithTitle:(NSString *)title;

@end

@implementation NGObjCToggleRowView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = title;
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];

        _toggleSwitch = [UISwitch new];
        _toggleSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        _toggleSwitch.onTintColor = [UIColor colorWithRed:0.27 green:0.93 blue:1.0 alpha:1.0];

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, _toggleSwitch]];
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.alignment = UIStackViewAlignmentCenter;

        [self addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.topAnchor constraintEqualToAnchor:self.topAnchor],
            [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

@end

@interface NGObjCMenuRowView : UIView

@property (nonatomic, strong, readonly) UIButton *selectionButton;

- (instancetype)initWithTitle:(NSString *)title;
- (void)setSelectionTitle:(NSString *)title;

@end

@implementation NGObjCMenuRowView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = title;
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];

        UIButtonConfiguration *configuration = [UIButtonConfiguration tintedButtonConfiguration];
        configuration.baseForegroundColor = UIColor.whiteColor;
        configuration.baseBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        configuration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
        configuration.image = [UIImage systemImageNamed:@"chevron.up.chevron.down"];
        configuration.imagePlacement = NSDirectionalRectEdgeTrailing;
        configuration.imagePadding = 8;

        _selectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _selectionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _selectionButton.configuration = configuration;
        _selectionButton.showsMenuAsPrimaryAction = YES;

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, _selectionButton]];
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;

        [_selectionButton.widthAnchor constraintGreaterThanOrEqualToConstant:156].active = YES;

        [self addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.topAnchor constraintEqualToAnchor:self.topAnchor],
            [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)setSelectionTitle:(NSString *)title {
    self.selectionButton.configuration.title = title;
}

@end

@interface NGObjCViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) NGObjCGradientBackdropView *previewBackgroundView;
@property (nonatomic, strong) UIView *previewMaskView;
@property (nonatomic, strong) UILabel *previewTitleLabel;
@property (nonatomic, strong) UILabel *previewDescLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *touchIndicatorView;
@property (nonatomic, strong) NGNeonGlowView *neonView;

@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, strong) UIStackView *controlStackView;
@property (nonatomic, strong) NGObjCMenuRowView *showAnimationRow;
@property (nonatomic, strong) NGObjCMenuRowView *dismissAnimationRow;
@property (nonatomic, strong) NGObjCToggleRowView *matchCornersRow;
@property (nonatomic, strong) NGObjCToggleRowView *distortionRow;
@property (nonatomic, strong) NGObjCToggleRowView *touchIndicatorRow;

@property (nonatomic, strong) NGObjCSliderRowView *showDurationRow;
@property (nonatomic, strong) NGObjCSliderRowView *dismissDurationRow;
@property (nonatomic, strong) NGObjCSliderRowView *borderWidthRow;
@property (nonatomic, strong) NGObjCSliderRowView *cornerRadiusRow;
@property (nonatomic, strong) NGObjCSliderRowView *glowInnerRow;
@property (nonatomic, strong) NGObjCSliderRowView *glowOuterRow;
@property (nonatomic, strong) NGObjCSliderRowView *glowIntensityRow;
@property (nonatomic, strong) NGObjCSliderRowView *lensRingRow;
@property (nonatomic, strong) NGObjCSliderRowView *flowSpeedRow;
@property (nonatomic, strong) NGObjCSliderRowView *animationSpeedRow;

@property (nonatomic, strong) UIButton *triggerCenterButton;
@property (nonatomic, strong) UIButton *randomBurstButton;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *flowButton;
@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic, strong) NSLayoutConstraint *neonTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *neonLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *neonTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *neonBottomConstraint;

@property (nonatomic, assign) BOOL flowing;
@property (nonatomic, assign) BOOL distortionEnabled;
@property (nonatomic, assign) BOOL touchIndicatorEnabled;
@property (nonatomic, assign) NGNeonGlowAnimation showAnimation;
@property (nonatomic, assign) NGNeonGlowAnimation dismissAnimation;
@property (nonatomic, assign) NSTimeInterval showDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;

@end

@implementation NGObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NeonGlow ObjC";
    [self setupUI];
    [self setupConstraints];
    [self setupActions];
    [self resetControlsToDefaults];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.flowing) {
        [self.neonView startFlowing];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.neonView stopFlowing];
    [self.neonView clearDistortionSource];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:0.03 green:0.05 blue:0.10 alpha:1.0];

    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"NeonGlow ObjC";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBlack];

    self.subtitleLabel = [UILabel new];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.text = @"Objective-C 版同样加入了完整控制台。你可以直接调动画类型、速度、辉光、圆角、流动速度与背景扭曲。";
    self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.72];
    self.subtitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.subtitleLabel.numberOfLines = 0;

    self.previewContainer = [UIView new];
    self.previewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    self.previewContainer.layer.cornerRadius = 28;
    self.previewContainer.layer.masksToBounds = YES;

    self.previewBackgroundView = [NGObjCGradientBackdropView new];
    self.previewBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;

    self.previewMaskView = [UIView new];
    self.previewMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewMaskView.backgroundColor = [UIColor colorWithRed:0.02 green:0.03 blue:0.08 alpha:0.34];

    self.previewTitleLabel = [UILabel new];
    self.previewTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewTitleLabel.textColor = UIColor.whiteColor;
    self.previewTitleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightSemibold];

    self.previewDescLabel = [UILabel new];
    self.previewDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewDescLabel.text = @"Double tap anywhere on the card. The burst starts from the touch point and stays on the original Objective-C shader pipeline.";
    self.previewDescLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.88];
    self.previewDescLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.previewDescLabel.numberOfLines = 0;

    self.tipLabel = [UILabel new];
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipLabel.text = @"Swift target exposes the same control panel for side-by-side comparison.";
    self.tipLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.58];
    self.tipLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    self.tipLabel.numberOfLines = 0;

    self.touchIndicatorView = [UIView new];
    self.touchIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.touchIndicatorView.backgroundColor = UIColor.clearColor;
    self.touchIndicatorView.layer.cornerRadius = 14;
    self.touchIndicatorView.layer.borderWidth = 2;
    self.touchIndicatorView.layer.borderColor = [UIColor colorWithRed:71.0 / 255.0 green:216.0 / 255.0 blue:1.0 alpha:0.95].CGColor;
    self.touchIndicatorView.hidden = YES;

    self.neonView = [NGNeonGlowView new];
    self.neonView.translatesAutoresizingMaskIntoConstraints = NO;

    self.controlPanelView = [UIView new];
    self.controlPanelView.translatesAutoresizingMaskIntoConstraints = NO;
    self.controlPanelView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
    self.controlPanelView.layer.cornerRadius = 28;
    self.controlPanelView.layer.borderWidth = 1;
    self.controlPanelView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;

    self.controlStackView = [UIStackView new];
    self.controlStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.controlStackView.axis = UILayoutConstraintAxisVertical;
    self.controlStackView.spacing = 16;

    self.showAnimationRow = [[NGObjCMenuRowView alloc] initWithTitle:@"Show Animation"];
    self.dismissAnimationRow = [[NGObjCMenuRowView alloc] initWithTitle:@"Dismiss Animation"];
    self.matchCornersRow = [[NGObjCToggleRowView alloc] initWithTitle:@"Match Screen Corner Radius"];
    self.distortionRow = [[NGObjCToggleRowView alloc] initWithTitle:@"Use Background Distortion"];
    self.touchIndicatorRow = [[NGObjCToggleRowView alloc] initWithTitle:@"Show Touch Indicator"];

    self.showDurationRow = [self makeSliderRowWithTitle:@"Show Duration" tag:NGObjCSliderTagShowDuration min:0.15 max:3.0];
    self.dismissDurationRow = [self makeSliderRowWithTitle:@"Dismiss Duration" tag:NGObjCSliderTagDismissDuration min:0.10 max:2.0];
    self.borderWidthRow = [self makeSliderRowWithTitle:@"Border Width" tag:NGObjCSliderTagBorderWidth min:1.0 max:12.0];
    self.cornerRadiusRow = [self makeSliderRowWithTitle:@"Corner Radius" tag:NGObjCSliderTagCornerRadius min:0.0 max:80.0];
    self.glowInnerRow = [self makeSliderRowWithTitle:@"Glow Inner Spread" tag:NGObjCSliderTagGlowInner min:0.0 max:80.0];
    self.glowOuterRow = [self makeSliderRowWithTitle:@"Glow Outer Spread" tag:NGObjCSliderTagGlowOuter min:0.0 max:36.0];
    self.glowIntensityRow = [self makeSliderRowWithTitle:@"Glow Intensity" tag:NGObjCSliderTagGlowIntensity min:0.0 max:1.5];
    self.lensRingRow = [self makeSliderRowWithTitle:@"Lens Ring Intensity" tag:NGObjCSliderTagLensRing min:0.0 max:1.2];
    self.flowSpeedRow = [self makeSliderRowWithTitle:@"Flow Speed" tag:NGObjCSliderTagFlowSpeed min:0.0 max:0.8];
    self.animationSpeedRow = [self makeSliderRowWithTitle:@"Animation Speed Multiplier" tag:NGObjCSliderTagAnimationSpeed min:0.2 max:3.0];

    self.triggerCenterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.randomBurstButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flowButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];

    [self styleButton:self.triggerCenterButton title:@"Trigger Center"];
    [self styleButton:self.randomBurstButton title:@"Random Burst"];
    [self styleButton:self.dismissButton title:@"Dismiss"];
    [self styleButton:self.flowButton title:@"Pause Flow"];
    [self styleButton:self.resetButton title:@"Reset"];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.previewContainer];
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.controlPanelView];
    [self.controlPanelView addSubview:self.controlStackView];
    [self.contentView addSubview:self.neonView];

    [self.previewContainer addSubview:self.previewBackgroundView];
    [self.previewContainer addSubview:self.previewMaskView];
    [self.previewContainer addSubview:self.previewTitleLabel];
    [self.previewContainer addSubview:self.previewDescLabel];
    [self.previewContainer addSubview:self.touchIndicatorView];

    [self addSectionWithTitle:@"Animation"];
    [self.controlStackView addArrangedSubview:self.showAnimationRow];
    [self.controlStackView addArrangedSubview:self.dismissAnimationRow];
    [self.controlStackView addArrangedSubview:self.showDurationRow];
    [self.controlStackView addArrangedSubview:self.dismissDurationRow];

    [self addSectionWithTitle:@"Appearance"];
    [self.controlStackView addArrangedSubview:self.borderWidthRow];
    [self.controlStackView addArrangedSubview:self.cornerRadiusRow];
    [self.controlStackView addArrangedSubview:self.glowInnerRow];
    [self.controlStackView addArrangedSubview:self.glowOuterRow];
    [self.controlStackView addArrangedSubview:self.glowIntensityRow];
    [self.controlStackView addArrangedSubview:self.lensRingRow];

    [self addSectionWithTitle:@"Behavior"];
    [self.controlStackView addArrangedSubview:self.flowSpeedRow];
    [self.controlStackView addArrangedSubview:self.animationSpeedRow];
    [self.controlStackView addArrangedSubview:self.matchCornersRow];
    [self.controlStackView addArrangedSubview:self.distortionRow];
    [self.controlStackView addArrangedSubview:self.touchIndicatorRow];

    [self addSectionWithTitle:@"Actions"];
    [self.controlStackView addArrangedSubview:[self makeActionRows]];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:28],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],

        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12],
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],

        [self.previewContainer.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:28],
        [self.previewContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.previewContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.previewContainer.heightAnchor constraintEqualToConstant:360],

        [self.previewBackgroundView.topAnchor constraintEqualToAnchor:self.previewContainer.topAnchor],
        [self.previewBackgroundView.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor],
        [self.previewBackgroundView.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor],
        [self.previewBackgroundView.bottomAnchor constraintEqualToAnchor:self.previewContainer.bottomAnchor],

        [self.previewMaskView.topAnchor constraintEqualToAnchor:self.previewContainer.topAnchor],
        [self.previewMaskView.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor],
        [self.previewMaskView.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor],
        [self.previewMaskView.bottomAnchor constraintEqualToAnchor:self.previewContainer.bottomAnchor],

        [self.previewTitleLabel.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor constant:24],
        [self.previewTitleLabel.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor constant:-24],
        [self.previewTitleLabel.bottomAnchor constraintEqualToAnchor:self.previewDescLabel.topAnchor constant:-12],

        [self.previewDescLabel.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor constant:24],
        [self.previewDescLabel.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor constant:-24],
        [self.previewDescLabel.bottomAnchor constraintEqualToAnchor:self.previewContainer.bottomAnchor constant:-30],

        [self.touchIndicatorView.widthAnchor constraintEqualToConstant:28],
        [self.touchIndicatorView.heightAnchor constraintEqualToConstant:28],

        [self.tipLabel.topAnchor constraintEqualToAnchor:self.previewContainer.bottomAnchor constant:24],
        [self.tipLabel.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor],
        [self.tipLabel.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor],

        [self.controlPanelView.topAnchor constraintEqualToAnchor:self.tipLabel.bottomAnchor constant:20],
        [self.controlPanelView.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor],
        [self.controlPanelView.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor],
        [self.controlPanelView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-32],

        [self.controlStackView.topAnchor constraintEqualToAnchor:self.controlPanelView.topAnchor constant:20],
        [self.controlStackView.leadingAnchor constraintEqualToAnchor:self.controlPanelView.leadingAnchor constant:18],
        [self.controlStackView.trailingAnchor constraintEqualToAnchor:self.controlPanelView.trailingAnchor constant:-18],
        [self.controlStackView.bottomAnchor constraintEqualToAnchor:self.controlPanelView.bottomAnchor constant:-20],
    ]];

    self.neonTopConstraint = [self.neonView.topAnchor constraintEqualToAnchor:self.previewContainer.topAnchor];
    self.neonLeadingConstraint = [self.neonView.leadingAnchor constraintEqualToAnchor:self.previewContainer.leadingAnchor];
    self.neonTrailingConstraint = [self.neonView.trailingAnchor constraintEqualToAnchor:self.previewContainer.trailingAnchor];
    self.neonBottomConstraint = [self.neonView.bottomAnchor constraintEqualToAnchor:self.previewContainer.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        self.neonTopConstraint,
        self.neonLeadingConstraint,
        self.neonTrailingConstraint,
        self.neonBottomConstraint,
    ]];
}

- (void)setupActions {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePreviewDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.previewContainer addGestureRecognizer:doubleTap];

    [self.triggerCenterButton addTarget:self action:@selector(handleTriggerCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.randomBurstButton addTarget:self action:@selector(handleRandomBurst) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton addTarget:self action:@selector(handleDismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.flowButton addTarget:self action:@selector(handleFlowToggle) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton addTarget:self action:@selector(handleReset) forControlEvents:UIControlEventTouchUpInside];

    [self.matchCornersRow.toggleSwitch addTarget:self action:@selector(handleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.distortionRow.toggleSwitch addTarget:self action:@selector(handleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.touchIndicatorRow.toggleSwitch addTarget:self action:@selector(handleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)resetControlsToDefaults {
    self.showAnimation = NGNeonGlowAnimationWave;
    self.dismissAnimation = NGNeonGlowAnimationFade;
    self.showDuration = 1.2;
    self.dismissDuration = 0.35;
    self.flowing = YES;
    self.distortionEnabled = YES;
    self.touchIndicatorEnabled = YES;

    self.showDurationRow.slider.value = (float)self.showDuration;
    self.dismissDurationRow.slider.value = (float)self.dismissDuration;
    self.borderWidthRow.slider.value = 3.0;
    self.cornerRadiusRow.slider.value = 28.0;
    self.glowInnerRow.slider.value = 32.0;
    self.glowOuterRow.slider.value = 14.0;
    self.glowIntensityRow.slider.value = 0.9;
    self.lensRingRow.slider.value = 0.3;
    self.flowSpeedRow.slider.value = 0.15;
    self.animationSpeedRow.slider.value = 1.0;

    self.matchCornersRow.toggleSwitch.on = NO;
    self.distortionRow.toggleSwitch.on = self.distortionEnabled;
    self.touchIndicatorRow.toggleSwitch.on = self.touchIndicatorEnabled;

    [self applyCurrentConfiguration];
}

- (void)applyCurrentConfiguration {
    self.neonView.neonBorderWidth = self.borderWidthRow.slider.value;
    self.neonView.glowInnerSpread = self.glowInnerRow.slider.value;
    self.neonView.glowOuterSpread = self.glowOuterRow.slider.value;
    self.neonView.glowIntensity = self.glowIntensityRow.slider.value;
    self.neonView.lensRingIntensity = self.lensRingRow.slider.value;
    self.neonView.flowSpeed = self.flowSpeedRow.slider.value;
    self.neonView.animationSpeedMultiplier = self.animationSpeedRow.slider.value;

    if (self.matchCornersRow.toggleSwitch.isOn) {
        self.neonView.matchesScreenCornerRadius = YES;
    } else {
        self.neonView.matchesScreenCornerRadius = NO;
        self.neonView.neonCornerRadius = self.cornerRadiusRow.slider.value;
    }

    CGFloat resolvedCornerRadius = self.neonView.neonCornerRadius;
    self.previewContainer.layer.cornerRadius = resolvedCornerRadius;

    CGFloat outerGlow = self.neonView.glowOuterSpread;
    self.neonTopConstraint.constant = -outerGlow;
    self.neonLeadingConstraint.constant = -outerGlow;
    self.neonTrailingConstraint.constant = outerGlow;
    self.neonBottomConstraint.constant = outerGlow;

    self.showDuration = self.showDurationRow.slider.value;
    self.dismissDuration = self.dismissDurationRow.slider.value;
    self.distortionEnabled = self.distortionRow.toggleSwitch.isOn;
    self.touchIndicatorEnabled = self.touchIndicatorRow.toggleSwitch.isOn;

    [self.showDurationRow setValueText:[self formatFloat:self.showDuration digits:2]];
    [self.dismissDurationRow setValueText:[self formatFloat:self.dismissDuration digits:2]];
    [self.borderWidthRow setValueText:[self formatFloat:self.borderWidthRow.slider.value digits:1]];
    if (self.matchCornersRow.toggleSwitch.isOn) {
        [self.cornerRadiusRow setValueText:[NSString stringWithFormat:@"Auto %@", [self formatFloat:resolvedCornerRadius digits:1]]];
    } else {
        [self.cornerRadiusRow setValueText:[self formatFloat:self.cornerRadiusRow.slider.value digits:1]];
    }
    [self.glowInnerRow setValueText:[self formatFloat:self.glowInnerRow.slider.value digits:1]];
    [self.glowOuterRow setValueText:[self formatFloat:self.glowOuterRow.slider.value digits:1]];
    [self.glowIntensityRow setValueText:[self formatFloat:self.glowIntensityRow.slider.value digits:2]];
    [self.lensRingRow setValueText:[self formatFloat:self.lensRingRow.slider.value digits:2]];
    [self.flowSpeedRow setValueText:[self formatFloat:self.flowSpeedRow.slider.value digits:2]];
    [self.animationSpeedRow setValueText:[self formatFloat:self.animationSpeedRow.slider.value digits:2]];

    [self.showAnimationRow setSelectionTitle:[self titleForAnimation:self.showAnimation]];
    [self.dismissAnimationRow setSelectionTitle:[self titleForAnimation:self.dismissAnimation]];
    self.previewTitleLabel.text = [NSString stringWithFormat:@"NEON %@", [[self titleForAnimation:self.showAnimation] uppercaseString]];
    self.flowButton.configuration.title = self.flowing ? @"Pause Flow" : @"Resume Flow";

    [self rebuildAnimationMenus];
    [self.view layoutIfNeeded];
}

- (void)rebuildAnimationMenus {
    __weak typeof(self) weakSelf = self;
    self.showAnimationRow.selectionButton.menu = [self menuForCurrentAnimation:self.showAnimation handler:^(NGNeonGlowAnimation animation) {
        weakSelf.showAnimation = animation;
        [weakSelf applyCurrentConfiguration];
    }];
    self.dismissAnimationRow.selectionButton.menu = [self menuForCurrentAnimation:self.dismissAnimation handler:^(NGNeonGlowAnimation animation) {
        weakSelf.dismissAnimation = animation;
        [weakSelf applyCurrentConfiguration];
    }];
}

- (UIMenu *)menuForCurrentAnimation:(NGNeonGlowAnimation)current handler:(void (^)(NGNeonGlowAnimation animation))handler {
    NSMutableArray<UIMenuElement *> *actions = [NSMutableArray array];
    for (NSNumber *number in @[@(NGNeonGlowAnimationNone), @(NGNeonGlowAnimationFade), @(NGNeonGlowAnimationWave), @(NGNeonGlowAnimationLens), @(NGNeonGlowAnimationTrace)]) {
        NGNeonGlowAnimation animation = number.integerValue;
        UIAction *action = [UIAction actionWithTitle:[self titleForAnimation:animation] image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            handler(animation);
        }];
        action.state = animation == current ? UIMenuElementStateOn : UIMenuElementStateOff;
        [actions addObject:action];
    }
    return [UIMenu menuWithOptions:UIMenuOptionsDisplayInline children:actions];
}

- (NGObjCSliderRowView *)makeSliderRowWithTitle:(NSString *)title tag:(NGObjCSliderTag)tag min:(float)min max:(float)max {
    NGObjCSliderRowView *row = [[NGObjCSliderRowView alloc] initWithTitle:title];
    row.slider.minimumValue = min;
    row.slider.maximumValue = max;
    row.slider.tag = tag;
    [row.slider addTarget:self action:@selector(handleSliderChanged:) forControlEvents:UIControlEventValueChanged];
    return row;
}

- (void)addSectionWithTitle:(NSString *)title {
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [self.controlStackView addArrangedSubview:label];
}

- (UIView *)makeActionRows {
    UIStackView *verticalStack = [UIStackView new];
    verticalStack.axis = UILayoutConstraintAxisVertical;
    verticalStack.spacing = 12;

    UIStackView *firstRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.triggerCenterButton, self.randomBurstButton, self.dismissButton]];
    firstRow.axis = UILayoutConstraintAxisHorizontal;
    firstRow.spacing = 10;
    firstRow.distribution = UIStackViewDistributionFillEqually;

    UIStackView *secondRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.flowButton, self.resetButton]];
    secondRow.axis = UILayoutConstraintAxisHorizontal;
    secondRow.spacing = 10;
    secondRow.distribution = UIStackViewDistributionFillEqually;

    for (UIButton *button in @[self.triggerCenterButton, self.randomBurstButton, self.dismissButton, self.flowButton, self.resetButton]) {
        [button.heightAnchor constraintEqualToConstant:50].active = YES;
    }

    [verticalStack addArrangedSubview:firstRow];
    [verticalStack addArrangedSubview:secondRow];
    return verticalStack;
}

- (void)styleButton:(UIButton *)button title:(NSString *)title {
    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.title = title;
    configuration.baseForegroundColor = UIColor.whiteColor;
    configuration.baseBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    configuration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    button.configuration = configuration;
}

- (NSString *)titleForAnimation:(NGNeonGlowAnimation)animation {
    switch (animation) {
        case NGNeonGlowAnimationNone: return @"None";
        case NGNeonGlowAnimationFade: return @"Fade";
        case NGNeonGlowAnimationWave: return @"Wave";
        case NGNeonGlowAnimationLens: return @"Lens";
        case NGNeonGlowAnimationTrace: return @"Trace";
    }
}

- (NSString *)formatFloat:(CGFloat)value digits:(NSInteger)digits {
    return [NSString stringWithFormat:@"%.*f", (int)digits, value];
}

- (void)handlePreviewDoubleTap:(UITapGestureRecognizer *)gesture {
    [self triggerNeonAtPoint:[gesture locationInView:self.previewContainer]];
}

- (void)handleTriggerCenter {
    CGPoint point = CGPointMake(CGRectGetMidX(self.previewContainer.bounds), CGRectGetMidY(self.previewContainer.bounds));
    [self triggerNeonAtPoint:point];
}

- (void)handleRandomBurst {
    CGFloat inset = 30.0;
    CGFloat width = MAX(CGRectGetWidth(self.previewContainer.bounds) - inset * 2.0, 1.0);
    CGFloat height = MAX(CGRectGetHeight(self.previewContainer.bounds) - inset * 2.0, 1.0);
    CGPoint point = CGPointMake(inset + ((CGFloat)arc4random() / UINT32_MAX) * width,
                                inset + ((CGFloat)arc4random() / UINT32_MAX) * height);
    [self triggerNeonAtPoint:point];
}

- (void)handleDismiss {
    __weak typeof(self) weakSelf = self;
    [self.neonView dismissWithAnimation:self.dismissAnimation
                               duration:self.dismissDuration
                             completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.neonView clearDistortionSource];
        if (strongSelf.flowing) {
            [strongSelf.neonView startFlowing];
        } else {
            [strongSelf.neonView stopFlowing];
        }
    }];
}

- (void)handleFlowToggle {
    self.flowing = !self.flowing;
    if (self.flowing) {
        [self.neonView startFlowing];
    } else {
        [self.neonView stopFlowing];
    }
    [self applyCurrentConfiguration];
}

- (void)handleReset {
    [self resetControlsToDefaults];
}

- (void)handleSliderChanged:(UISlider *)slider {
    if (slider.tag == NGObjCSliderTagCornerRadius && self.matchCornersRow.toggleSwitch.isOn) {
        self.matchCornersRow.toggleSwitch.on = NO;
    }
    [self applyCurrentConfiguration];
}

- (void)handleSwitchChanged:(UISwitch *)sender {
    [self applyCurrentConfiguration];
}

- (void)triggerNeonAtPoint:(CGPoint)point {
    CGSize neonSize = self.neonView.bounds.size;
    if (neonSize.width < 1 || neonSize.height < 1) {
        return;
    }

    CGFloat outerGlow = self.neonView.glowOuterSpread;
    CGPoint normalizedPoint = CGPointMake((point.x + outerGlow) / neonSize.width,
                                          (point.y + outerGlow) / neonSize.height);

    if (self.touchIndicatorEnabled) {
        [self showTouchIndicatorAtPoint:point];
    }

    self.neonView.hidden = YES;
    [self.neonView stopFlowing];
    [self.neonView clearDistortionSource];
    if (self.distortionEnabled) {
        [self.neonView prepareDistortionWithView:self.previewContainer];
    }
    [self.neonView showWithAnimation:self.showAnimation
                            duration:self.showDuration
                           fromPoint:normalizedPoint
                          completion:nil];
    if (self.flowing) {
        [self.neonView startFlowing];
    }
}

- (void)showTouchIndicatorAtPoint:(CGPoint)point {
    self.touchIndicatorView.hidden = NO;
    self.touchIndicatorView.alpha = 1.0;
    self.touchIndicatorView.transform = CGAffineTransformIdentity;
    self.touchIndicatorView.center = point;

    [UIView animateWithDuration:0.65
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.touchIndicatorView.alpha = 0.0;
        self.touchIndicatorView.transform = CGAffineTransformMakeScale(2.1, 2.1);
    } completion:^(BOOL finished) {
        self.touchIndicatorView.hidden = YES;
        self.touchIndicatorView.transform = CGAffineTransformIdentity;
    }];
}

@end
