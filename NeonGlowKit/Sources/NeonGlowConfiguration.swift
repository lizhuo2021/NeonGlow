//
//  NeonGlowConfiguration.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import Foundation
import UIKit

public struct NeonGlowConfiguration: Sendable {
    public var neonBorderWidth: CGFloat
    public var neonCornerRadius: CGFloat
    public var matchesScreenCornerRadius: Bool
    public var glowInnerSpread: CGFloat
    public var glowOuterSpread: CGFloat
    public var glowIntensity: CGFloat
    public var lensRingIntensity: CGFloat
    public var flowSpeed: CGFloat
    public var animationSpeedMultiplier: CGFloat

    public init(
        neonBorderWidth: CGFloat = 3.0,
        neonCornerRadius: CGFloat = 20.0,
        matchesScreenCornerRadius: Bool = false,
        glowInnerSpread: CGFloat = 25.0,
        glowOuterSpread: CGFloat = 10.0,
        glowIntensity: CGFloat = 0.8,
        lensRingIntensity: CGFloat = 0.3,
        flowSpeed: CGFloat = 0.15,
        animationSpeedMultiplier: CGFloat = 1.0
    ) {
        self.neonBorderWidth = neonBorderWidth
        self.neonCornerRadius = neonCornerRadius
        self.matchesScreenCornerRadius = matchesScreenCornerRadius
        self.glowInnerSpread = glowInnerSpread
        self.glowOuterSpread = glowOuterSpread
        self.glowIntensity = glowIntensity
        self.lensRingIntensity = lensRingIntensity
        self.flowSpeed = flowSpeed
        self.animationSpeedMultiplier = animationSpeedMultiplier
    }
}

public extension NeonGlowConfiguration {
    static func showcaseStyle() -> NeonGlowConfiguration {
        NeonGlowConfiguration(
            neonBorderWidth: 3.0,
            neonCornerRadius: 28.0,
            matchesScreenCornerRadius: false,
            glowInnerSpread: 32.0,
            glowOuterSpread: 14.0,
            glowIntensity: 0.9,
            lensRingIntensity: 0.3,
            flowSpeed: 0.15,
            animationSpeedMultiplier: 1.0
        )
    }

    static func fullScreenStyle() -> NeonGlowConfiguration {
        NeonGlowConfiguration(
            neonBorderWidth: 3.0,
            neonCornerRadius: 20.0,
            matchesScreenCornerRadius: true,
            glowInnerSpread: 30.0,
            glowOuterSpread: 14.0,
            glowIntensity: 0.9,
            lensRingIntensity: 0.3,
            flowSpeed: 0.15,
            animationSpeedMultiplier: 1.0
        )
    }
}
