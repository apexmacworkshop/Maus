//
//  AccessibilityManager.swift
//  Maus
//
//  Created by Ziqian Huang on 2025/6/27.
//

import Foundation
import ApplicationServices
import AppKit

class AccessibilityManager: ObservableObject {
    @Published var isAccessGranted: Bool = false
    @Published var showPermissionAlert: Bool = false
    
    init() {
        checkAccessibilityPermissions()
        // Periodic check for accessibility status
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAccessibilityPermissions()
        }
    }
    
    func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        DispatchQueue.main.async {
            if self.isAccessGranted != trusted {
                self.isAccessGranted = trusted
                if !trusted {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    self.showPermissionAlert = true
                }
            }
        }
    }
    
    func requestAccessibilityPermissions() {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        }
    }
    
    func openSystemPreferences() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
