//
//  HomeView.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import SwiftUI

struct HomeView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwiftNeonGlowShowcaseViewController {
        SwiftNeonGlowShowcaseViewController()
    }

    func updateUIViewController(_ uiViewController: SwiftNeonGlowShowcaseViewController, context: Context) {}
}
