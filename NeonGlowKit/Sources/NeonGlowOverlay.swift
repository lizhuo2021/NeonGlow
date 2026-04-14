//
//  NeonGlowOverlay.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import SwiftUI

/// Usage:
/// `NeonGlowOverlay(controller: controller, configuration: .showcaseStyle(), isFlowing: true)`
public struct NeonGlowOverlay: UIViewRepresentable {
    public let controller: NeonGlowController
    public let configuration: NeonGlowConfiguration
    public let isFlowing: Bool

    public init(
        controller: NeonGlowController,
        configuration: NeonGlowConfiguration,
        isFlowing: Bool = true
    ) {
        self.controller = controller
        self.configuration = configuration
        self.isFlowing = isFlowing
    }

    public func makeUIView(context: Context) -> NeonGlowView {
        let view = NeonGlowView()
        view.configuration = configuration
        controller.view = view
        if isFlowing {
            view.startFlowing()
        }
        return view
    }

    public func updateUIView(_ uiView: NeonGlowView, context: Context) {
        uiView.configuration = configuration
        controller.view = uiView
        if isFlowing {
            uiView.startFlowing()
        } else {
            uiView.stopFlowing()
        }
    }
}
