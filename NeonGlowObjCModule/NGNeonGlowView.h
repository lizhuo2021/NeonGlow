//
//  NGNeonGlowView.h
//  NeonGlowObjC
//
//  Created by 李琢 on 2026/04/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NGNeonGlowAnimation) {
    NGNeonGlowAnimationNone = 0,
    NGNeonGlowAnimationFade,
    NGNeonGlowAnimationWave,
    NGNeonGlowAnimationLens,
    NGNeonGlowAnimationTrace,
};

@interface NGNeonGlowView : UIView

#pragma mark - Appearance

@property (nonatomic, assign) CGFloat neonBorderWidth;
@property (nonatomic, assign) CGFloat neonCornerRadius;
@property (nonatomic, assign) BOOL matchesScreenCornerRadius;
@property (nonatomic, assign) CGFloat glowInnerSpread;
@property (nonatomic, assign) CGFloat glowOuterSpread;
@property (nonatomic, assign) CGFloat glowIntensity;
@property (nonatomic, assign) CGFloat lensRingIntensity;

#pragma mark - Animation

@property (nonatomic, assign) CGFloat flowSpeed;
@property (nonatomic, assign) CGFloat animationSpeedMultiplier;

#pragma mark - Distortion

- (void)prepareDistortionWithView:(UIView *)sourceView;
- (void)clearDistortionSource;

#pragma mark - Control

- (void)startFlowing;
- (void)stopFlowing;

- (void)showWithAnimation:(NGNeonGlowAnimation)animation
                 duration:(NSTimeInterval)duration
                fromPoint:(CGPoint)point
               completion:(nullable void(^)(void))completion;

- (void)dismissWithAnimation:(NGNeonGlowAnimation)animation
                    duration:(NSTimeInterval)duration
                  completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
