//
//  NeonGlowController.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import CoreGraphics
import Foundation
import UIKit

@MainActor
public final class NeonGlowController: ObservableObject {
    weak var view: NeonGlowView?

    public init() {}

    public func prepareDistortion(with sourceView: UIView) {
        view?.prepareDistortion(with: sourceView)
    }

    public func clearDistortionSource() {
        view?.clearDistortionSource()
    }

    public func startFlowing() {
        view?.startFlowing()
    }

    public func stopFlowing() {
        view?.stopFlowing()
    }

    public func show(
        animation: NeonGlowAnimation,
        duration: TimeInterval,
        from normalizedPoint: CGPoint,
        completion: (() -> Void)? = nil
    ) {
        view?.show(animation: animation, duration: duration, from: normalizedPoint, completion: completion)
    }

    public func dismiss(
        animation: NeonGlowAnimation = .fade,
        duration: TimeInterval = 0.4,
        completion: (() -> Void)? = nil
    ) {
        view?.dismiss(animation: animation, duration: duration, completion: completion)
    }
}
