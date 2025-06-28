//
//  MausApp.swift
//  Maus
//
//  Created by Gordon.H Apex Mac Workshop on 2025/6/27.
//

import SwiftUI

@main
struct MausApp: App {
    @StateObject private var scrollManager = ScrollManager()
    @StateObject private var accessibilityManager = AccessibilityManager()
    @State private var hideFromDock = false // Changed to false (visible by default)
    
    var body: some Scene {
        MenuBarExtra("Maus", systemImage: "magicmouse.fill") {
            ContentView(scrollManager: scrollManager, hideFromDock: $hideFromDock)
                .environmentObject(accessibilityManager)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: hideFromDock) { newValue in
            NSApplication.shared.setActivationPolicy(newValue ? .accessory : .regular)
            if !newValue {
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}
