//
//  ContentView.swift
//  Maus
//  Gordon.H Apex Mac Workshop 2025/6/27
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var scrollManager: ScrollManager
    @Binding var hideFromDock: Bool // Keep as binding
    @EnvironmentObject private var accessibilityManager: AccessibilityManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with version info
            VStack(alignment: .leading, spacing: 4) {
                Text("Maus")
                    .font(.system(size: 14, weight: .bold))
                Text("v1.0 · Gordon.H Apex Mac Workshop")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Divider()
            }
            
            // Main Toggle (disabled by default)
            Toggle("Enable Smooth Scrolling", isOn: $scrollManager.isEnabled)
                .toggleStyle(.switch)
                .disabled(scrollManager.needsAccessibility)
            
            if scrollManager.needsAccessibility {
                VStack(spacing: 8) {
                    Text("Accessibility Permission Required")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text("Enable in System Preferences > Security & Privacy > Accessibility")
                        .font(.caption)
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }) {
                        Text("Open System Preferences")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // Footer
            VStack(spacing: 4) {
                Divider()
                Toggle("Hide from Dock", isOn: $hideFromDock)
                    .toggleStyle(.switch)
                
                HStack {
                    Link("GitHub", destination: URL(string: "https://github.com/apexmacworkshop")!)
                        .font(.caption)
                    Spacer()
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(width: 240)
        .onAppear {
            scrollManager.checkAccessibility()
            scrollManager.checkForConflictingApps()
        }
    }
}
