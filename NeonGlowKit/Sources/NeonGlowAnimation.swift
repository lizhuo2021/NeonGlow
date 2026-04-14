//
//  NeonGlowAnimation.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import Foundation

public enum NeonGlowAnimation: String, CaseIterable, Identifiable, Sendable {
    case none
    case fade
    case wave
    case lens
    case trace

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .none: "None"
        case .fade: "Fade"
        case .wave: "Wave"
        case .lens: "Lens"
        case .trace: "Trace"
        }
    }
}
