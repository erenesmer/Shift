//
//  ShiftApp.swift
//  Shift
//
//  A modern window management app for macOS
//

import SwiftUI
import AppKit
import Carbon

@main
struct ShiftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            PreferencesView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotKeyRefs: [EventHotKeyRef] = []
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Shift starting...")
        
        // Setup menu bar first
        setupMenuBar()
        
        // Register hotkeys
        setupHotKeys()
        
        // Check accessibility permissions (will prompt user)
        checkAccessibilityPermissions()
        
        print("Shift ready!")
    }
    
    private func checkAccessibilityPermissions() {
        // This will prompt the user to grant permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if trusted {
            print("Accessibility permissions OK")
        } else {
            print("WARNING: Accessibility permissions not granted!")
            
            // Show alert
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Shift needs Accessibility permissions to move and resize windows.\n\n1. Open System Settings\n2. Go to Privacy & Security → Accessibility\n3. Enable Shift in the list\n\nYou may need to quit and relaunch Shift after granting permission."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Later")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    // Open Accessibility settings
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gearshift.layout.sixspeed", accessibilityDescription: "Shift")
        }
        
        let menu = NSMenu()
        
        // Window positioning actions
        let leftItem = NSMenuItem(title: "Left Half (⌘⌥⇧←)", action: #selector(tileLeft), keyEquivalent: "")
        leftItem.target = self
        menu.addItem(leftItem)
        
        let rightItem = NSMenuItem(title: "Right Half (⌘⌥⇧→)", action: #selector(tileRight), keyEquivalent: "")
        rightItem.target = self
        menu.addItem(rightItem)
        
        let topItem = NSMenuItem(title: "Top Half (⌘⌥⇧↑)", action: #selector(tileTop), keyEquivalent: "")
        topItem.target = self
        menu.addItem(topItem)
        
        let bottomItem = NSMenuItem(title: "Bottom Half (⌘⌥⇧↓)", action: #selector(tileBottom), keyEquivalent: "")
        bottomItem.target = self
        menu.addItem(bottomItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let maximizeItem = NSMenuItem(title: "Maximize (⌘⌥⇧M)", action: #selector(maximize), keyEquivalent: "")
        maximizeItem.target = self
        menu.addItem(maximizeItem)
        
        let centerItem = NSMenuItem(title: "Center (⌘⌥⇧C)", action: #selector(center), keyEquivalent: "")
        centerItem.target = self
        menu.addItem(centerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let increaseSizeItem = NSMenuItem(title: "Increase Size (⌘⌥⇧+)", action: #selector(increaseSize), keyEquivalent: "")
        increaseSizeItem.target = self
        menu.addItem(increaseSizeItem)
        
        let decreaseSizeItem = NSMenuItem(title: "Decrease Size (⌘⌥⇧-)", action: #selector(decreaseSize), keyEquivalent: "")
        decreaseSizeItem.target = self
        menu.addItem(decreaseSizeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let topLeftItem = NSMenuItem(title: "Top Left (⌘⌥⇧1)", action: #selector(tileTopLeft), keyEquivalent: "")
        topLeftItem.target = self
        menu.addItem(topLeftItem)
        
        let topRightItem = NSMenuItem(title: "Top Right (⌘⌥⇧2)", action: #selector(tileTopRight), keyEquivalent: "")
        topRightItem.target = self
        menu.addItem(topRightItem)
        
        let bottomLeftItem = NSMenuItem(title: "Bottom Left (⌘⌥⇧3)", action: #selector(tileBottomLeft), keyEquivalent: "")
        bottomLeftItem.target = self
        menu.addItem(bottomLeftItem)
        
        let bottomRightItem = NSMenuItem(title: "Bottom Right (⌘⌥⇧4)", action: #selector(tileBottomRight), keyEquivalent: "")
        bottomRightItem.target = self
        menu.addItem(bottomRightItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let leftThirdItem = NSMenuItem(title: "Left Third (⌘⌥⇧5)", action: #selector(tileLeftThird), keyEquivalent: "")
        leftThirdItem.target = self
        menu.addItem(leftThirdItem)
        
        let centerThirdItem = NSMenuItem(title: "Center Third (⌘⌥⇧6)", action: #selector(tileCenterThird), keyEquivalent: "")
        centerThirdItem.target = self
        menu.addItem(centerThirdItem)
        
        let rightThirdItem = NSMenuItem(title: "Right Third (⌘⌥⇧7)", action: #selector(tileRightThird), keyEquivalent: "")
        rightThirdItem.target = self
        menu.addItem(rightThirdItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Shift", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func setupHotKeys() {
        // Install event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
                
                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1: WindowManager.shared.tileLeft()
                    case 2: WindowManager.shared.tileRight()
                    case 3: WindowManager.shared.tileTop()
                    case 4: WindowManager.shared.tileBottom()
                    case 5: WindowManager.shared.maximize()
                    case 6: WindowManager.shared.center()
                    case 7: WindowManager.shared.tileTopLeft()
                    case 8: WindowManager.shared.tileTopRight()
                    case 9: WindowManager.shared.tileBottomLeft()
                    case 10: WindowManager.shared.tileBottomRight()
                    case 11: WindowManager.shared.increaseSize()
                    case 12: WindowManager.shared.decreaseSize()
                    case 13: WindowManager.shared.tileLeftThird()
                    case 14: WindowManager.shared.tileCenterThird()
                    case 15: WindowManager.shared.tileRightThird()
                    default: break
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
        
        // Cmd + Option + Shift modifiers
        let modifiers: UInt32 = UInt32(cmdKey | optionKey | shiftKey)
        
        // Register: Cmd + Option + Shift + Left Arrow
        let hotKeyID1 = EventHotKeyID(signature: OSType(0x5348), id: 1)
        var hotKeyRef1: EventHotKeyRef?
        let status1 = RegisterEventHotKey(UInt32(kVK_LeftArrow), modifiers, hotKeyID1, GetApplicationEventTarget(), 0, &hotKeyRef1)
        print("Register Left: \(status1 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef1 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + Right Arrow
        let hotKeyID2 = EventHotKeyID(signature: OSType(0x5348), id: 2)
        var hotKeyRef2: EventHotKeyRef?
        let status2 = RegisterEventHotKey(UInt32(kVK_RightArrow), modifiers, hotKeyID2, GetApplicationEventTarget(), 0, &hotKeyRef2)
        print("Register Right: \(status2 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef2 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + Up Arrow
        let hotKeyID3 = EventHotKeyID(signature: OSType(0x5348), id: 3)
        var hotKeyRef3: EventHotKeyRef?
        let status3 = RegisterEventHotKey(UInt32(kVK_UpArrow), modifiers, hotKeyID3, GetApplicationEventTarget(), 0, &hotKeyRef3)
        print("Register Up: \(status3 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef3 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + Down Arrow
        let hotKeyID4 = EventHotKeyID(signature: OSType(0x5348), id: 4)
        var hotKeyRef4: EventHotKeyRef?
        let status4 = RegisterEventHotKey(UInt32(kVK_DownArrow), modifiers, hotKeyID4, GetApplicationEventTarget(), 0, &hotKeyRef4)
        print("Register Down: \(status4 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef4 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + M for Maximize
        let hotKeyID5 = EventHotKeyID(signature: OSType(0x5348), id: 5)
        var hotKeyRef5: EventHotKeyRef?
        let status5 = RegisterEventHotKey(UInt32(kVK_ANSI_M), modifiers, hotKeyID5, GetApplicationEventTarget(), 0, &hotKeyRef5)
        print("Register Maximize: \(status5 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef5 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + C for Center
        let hotKeyID6 = EventHotKeyID(signature: OSType(0x5348), id: 6)
        var hotKeyRef6: EventHotKeyRef?
        let status6 = RegisterEventHotKey(UInt32(kVK_ANSI_C), modifiers, hotKeyID6, GetApplicationEventTarget(), 0, &hotKeyRef6)
        print("Register Center: \(status6 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef6 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 1 for Top Left
        let hotKeyID7 = EventHotKeyID(signature: OSType(0x5348), id: 7)
        var hotKeyRef7: EventHotKeyRef?
        let status7 = RegisterEventHotKey(UInt32(kVK_ANSI_1), modifiers, hotKeyID7, GetApplicationEventTarget(), 0, &hotKeyRef7)
        print("Register Top Left: \(status7 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef7 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 2 for Top Right
        let hotKeyID8 = EventHotKeyID(signature: OSType(0x5348), id: 8)
        var hotKeyRef8: EventHotKeyRef?
        let status8 = RegisterEventHotKey(UInt32(kVK_ANSI_2), modifiers, hotKeyID8, GetApplicationEventTarget(), 0, &hotKeyRef8)
        print("Register Top Right: \(status8 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef8 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 3 for Bottom Left
        let hotKeyID9 = EventHotKeyID(signature: OSType(0x5348), id: 9)
        var hotKeyRef9: EventHotKeyRef?
        let status9 = RegisterEventHotKey(UInt32(kVK_ANSI_3), modifiers, hotKeyID9, GetApplicationEventTarget(), 0, &hotKeyRef9)
        print("Register Bottom Left: \(status9 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef9 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 4 for Bottom Right
        let hotKeyID10 = EventHotKeyID(signature: OSType(0x5348), id: 10)
        var hotKeyRef10: EventHotKeyRef?
        let status10 = RegisterEventHotKey(UInt32(kVK_ANSI_4), modifiers, hotKeyID10, GetApplicationEventTarget(), 0, &hotKeyRef10)
        print("Register Bottom Right: \(status10 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef10 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + = (plus) for Increase Size
        let hotKeyID11 = EventHotKeyID(signature: OSType(0x5348), id: 11)
        var hotKeyRef11: EventHotKeyRef?
        let status11 = RegisterEventHotKey(UInt32(kVK_ANSI_Equal), modifiers, hotKeyID11, GetApplicationEventTarget(), 0, &hotKeyRef11)
        print("Register Increase Size: \(status11 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef11 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + - (minus) for Decrease Size
        let hotKeyID12 = EventHotKeyID(signature: OSType(0x5348), id: 12)
        var hotKeyRef12: EventHotKeyRef?
        let status12 = RegisterEventHotKey(UInt32(kVK_ANSI_Minus), modifiers, hotKeyID12, GetApplicationEventTarget(), 0, &hotKeyRef12)
        print("Register Decrease Size: \(status12 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef12 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 5 for Left Third
        let hotKeyID13 = EventHotKeyID(signature: OSType(0x5348), id: 13)
        var hotKeyRef13: EventHotKeyRef?
        let status13 = RegisterEventHotKey(UInt32(kVK_ANSI_5), modifiers, hotKeyID13, GetApplicationEventTarget(), 0, &hotKeyRef13)
        print("Register Left Third: \(status13 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef13 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 6 for Center Third
        let hotKeyID14 = EventHotKeyID(signature: OSType(0x5348), id: 14)
        var hotKeyRef14: EventHotKeyRef?
        let status14 = RegisterEventHotKey(UInt32(kVK_ANSI_6), modifiers, hotKeyID14, GetApplicationEventTarget(), 0, &hotKeyRef14)
        print("Register Center Third: \(status14 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef14 { hotKeyRefs.append(ref) }
        
        // Register: Cmd + Option + Shift + 7 for Right Third
        let hotKeyID15 = EventHotKeyID(signature: OSType(0x5348), id: 15)
        var hotKeyRef15: EventHotKeyRef?
        let status15 = RegisterEventHotKey(UInt32(kVK_ANSI_7), modifiers, hotKeyID15, GetApplicationEventTarget(), 0, &hotKeyRef15)
        print("Register Right Third: \(status15 == noErr ? "OK" : "FAILED")")
        if let ref = hotKeyRef15 { hotKeyRefs.append(ref) }
    }
    
    // MARK: - Menu Actions
    @objc func tileLeft() { WindowManager.shared.tileLeft() }
    @objc func tileRight() { WindowManager.shared.tileRight() }
    @objc func tileTop() { WindowManager.shared.tileTop() }
    @objc func tileBottom() { WindowManager.shared.tileBottom() }
    @objc func maximize() { WindowManager.shared.maximize() }
    @objc func center() { WindowManager.shared.center() }
    @objc func tileTopLeft() { WindowManager.shared.tileTopLeft() }
    @objc func tileTopRight() { WindowManager.shared.tileTopRight() }
    @objc func tileBottomLeft() { WindowManager.shared.tileBottomLeft() }
    @objc func tileBottomRight() { WindowManager.shared.tileBottomRight() }
    @objc func increaseSize() { WindowManager.shared.increaseSize() }
    @objc func decreaseSize() { WindowManager.shared.decreaseSize() }
    @objc func tileLeftThird() { WindowManager.shared.tileLeftThird() }
    @objc func tileCenterThird() { WindowManager.shared.tileCenterThird() }
    @objc func tileRightThird() { WindowManager.shared.tileRightThird() }
}
