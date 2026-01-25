//
//  PreferencesView.swift
//  Shift
//
//  Preferences window for Shift
//

import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            HStack(spacing: 0) {
                TabButton(title: "General", icon: "gear", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Shortcuts", icon: "keyboard", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "About", icon: "info.circle", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Divider()
                .padding(.top, 10)
            
            // Content
            Group {
                switch selectedTab {
                case 0:
                    GeneralSettingsView(launchAtLogin: $launchAtLogin)
                case 1:
                    ShortcutsSettingsView()
                case 2:
                    AboutView()
                default:
                    GeneralSettingsView(launchAtLogin: $launchAtLogin)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 450, height: 320)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 80, height: 50)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Launch Shift at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(newValue)
                }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Accessibility Permissions")
                    .font(.headline)
                
                Text("Shift needs Accessibility permissions to manage windows.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Open Accessibility Settings") {
                    openAccessibilitySettings()
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

struct ShortcutsSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Keyboard Shortcuts")
                .font(.headline)
            
            Text("All shortcuts use ⌘ ⌥ ⇧ (Cmd + Option + Shift)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ShortcutRow(action: "Left Half", shortcut: "⌘ ⌥ ⇧ ←")
                    ShortcutRow(action: "Right Half", shortcut: "⌘ ⌥ ⇧ →")
                    ShortcutRow(action: "Top Half", shortcut: "⌘ ⌥ ⇧ ↑")
                    ShortcutRow(action: "Bottom Half", shortcut: "⌘ ⌥ ⇧ ↓")
                    
                    Divider()
                    
                    ShortcutRow(action: "Top Left", shortcut: "⌘ ⌥ ⇧ 1")
                    ShortcutRow(action: "Top Right", shortcut: "⌘ ⌥ ⇧ 2")
                    ShortcutRow(action: "Bottom Left", shortcut: "⌘ ⌥ ⇧ 3")
                    ShortcutRow(action: "Bottom Right", shortcut: "⌘ ⌥ ⇧ 4")
                    
                    Divider()
                    
                    ShortcutRow(action: "Maximize", shortcut: "⌘ ⌥ ⇧ M")
                    ShortcutRow(action: "Center", shortcut: "⌘ ⌥ ⇧ C")
                    
                    Divider()
                    
                    ShortcutRow(action: "Increase Size", shortcut: "⌘ ⌥ ⇧ +")
                    ShortcutRow(action: "Decrease Size", shortcut: "⌘ ⌥ ⇧ -")
                    
                    Divider()
                    
                    ShortcutRow(action: "Left Third", shortcut: "⌘ ⌥ ⇧ 5")
                    ShortcutRow(action: "Center Third", shortcut: "⌘ ⌥ ⇧ 6")
                    ShortcutRow(action: "Right Third", shortcut: "⌘ ⌥ ⇧ 7")
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ShortcutRow: View {
    let action: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(action)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshift.layout.sixspeed")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Shift")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0")
                .foregroundColor(.secondary)
            
            Text("A modern window management app for macOS")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PreferencesView()
}
