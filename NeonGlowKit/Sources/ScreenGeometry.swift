//
//  ScreenGeometry.swift
//  NeonGlow
//
//  Created by 李琢 on 2026/04/14.
//

import UIKit
import Darwin

enum ScreenGeometry {
    static func displayCornerRadiusForCurrentDevice() -> CGFloat {
        let identifier = currentDeviceIdentifier()

        if hasPrefix(identifier, prefixes: ["iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone11,4", "iPhone11,6", "iPhone12,3", "iPhone12,5"]) {
            return 39.0
        }

        if hasPrefix(identifier, prefixes: ["iPhone11,8", "iPhone12,1"]) {
            return 41.5
        }

        if hasPrefix(identifier, prefixes: ["iPhone13,1", "iPhone14,4"]) {
            return 44.0
        }

        if hasPrefix(identifier, prefixes: ["iPhone13,2", "iPhone13,3", "iPhone14,5", "iPhone14,7", "iPhone17,3"]) {
            return 47.33
        }

        if hasPrefix(identifier, prefixes: ["iPhone13,4", "iPhone14,3", "iPhone14,8"]) {
            return 53.33
        }

        if hasPrefix(identifier, prefixes: ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,1", "iPhone17,2"]) {
            return 55.0
        }

        if hasPrefix(identifier, prefixes: ["iPhone17,4", "iPhone17,5", "iPhone18,1", "iPhone18,2", "iPhone18,3", "iPhone18,4"]) {
            return 62.0
        }

        if identifier.hasPrefix("iPad") {
            return 18.0
        }

        return fallbackCornerRadius()
    }

    private static func currentDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }

        if machine == "x86_64" || machine == "arm64",
           let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
           !simulatorIdentifier.isEmpty {
            return simulatorIdentifier
        }

        return machine
    }

    private static func hasPrefix(_ identifier: String, prefixes: [String]) -> Bool {
        prefixes.contains { identifier.hasPrefix($0) }
    }

    private static func fallbackCornerRadius() -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return 18.0
        }

        let screenSize = fallbackScreenSize()
        let maxSide = max(screenSize.width, screenSize.height)
        let minSide = min(screenSize.width, screenSize.height)

        if maxSide >= 956.0 { return 62.0 }
        if maxSide >= 932.0 { return minSide >= 430.0 ? 55.0 : 47.33 }
        if maxSide >= 926.0 { return minSide >= 428.0 ? 53.33 : 47.33 }
        if maxSide >= 852.0 { return 55.0 }
        if maxSide >= 844.0 { return 47.33 }
        if maxSide >= 812.0 { return 39.0 }
        return 34.0
    }

    private static func fallbackScreenSize() -> CGSize {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .map { $0.screen.bounds.size }
            .first(where: { $0.width > 0 && $0.height > 0 }) ?? CGSize(width: 390, height: 844)
    }
}
