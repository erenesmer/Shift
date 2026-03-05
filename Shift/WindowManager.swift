//
//  WindowManager.swift
//  Shift
//
//  Handles window positioning using Accessibility API
//

import AppKit
import ApplicationServices

class WindowManager {
    static let shared = WindowManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func tileLeft() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY, width: f.width / 2, height: f.height)
    }
    
    func tileRight() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX + f.width / 2, y: f.minY, width: f.width / 2, height: f.height)
    }
    
    func tileTop() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY, width: f.width, height: f.height / 2)
    }
    
    func tileBottom() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY + f.height / 2, width: f.width, height: f.height / 2)
    }
    
    func maximize() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY, width: f.width, height: f.height)
    }
    
    func center() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        guard let currentSize = getWindowSize(window) else { return }
        
        let f = axVisibleFrame(for: screen)
        let x = f.minX + (f.width - currentSize.width) / 2
        let y = f.minY + (f.height - currentSize.height) / 2
        
        setWindowPosition(window, x: x, y: y)
    }
    
    func increaseSize() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        guard let currentSize = getWindowSize(window) else { return }
        guard let currentPosition = getWindowPosition(window) else { return }
        
        let f = axVisibleFrame(for: screen)
        
        let factor: CGFloat = 1.1
        let newWidth = min(currentSize.width * factor, f.width)
        let newHeight = min(currentSize.height * factor, f.height)
        
        let deltaWidth = newWidth - currentSize.width
        let deltaHeight = newHeight - currentSize.height
        let newX = max(f.minX, currentPosition.x - deltaWidth / 2)
        let newY = max(f.minY, currentPosition.y - deltaHeight / 2)
        
        setWindowFrame(window, x: newX, y: newY, width: newWidth, height: newHeight)
    }
    
    func decreaseSize() {
        guard let (window, _) = getWindowAndScreen() else { return }
        guard let currentSize = getWindowSize(window) else { return }
        guard let currentPosition = getWindowPosition(window) else { return }
        
        let factor: CGFloat = 0.9
        let minSize: CGFloat = 200
        let newWidth = max(currentSize.width * factor, minSize)
        let newHeight = max(currentSize.height * factor, minSize)
        
        let deltaWidth = currentSize.width - newWidth
        let deltaHeight = currentSize.height - newHeight
        let newX = currentPosition.x + deltaWidth / 2
        let newY = currentPosition.y + deltaHeight / 2
        
        setWindowFrame(window, x: newX, y: newY, width: newWidth, height: newHeight)
    }
    
    func tileTopLeft() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY, width: f.width / 2, height: f.height / 2)
    }
    
    func tileTopRight() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX + f.width / 2, y: f.minY, width: f.width / 2, height: f.height / 2)
    }
    
    func tileBottomLeft() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY + f.height / 2, width: f.width / 2, height: f.height / 2)
    }
    
    func tileBottomRight() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX + f.width / 2, y: f.minY + f.height / 2, width: f.width / 2, height: f.height / 2)
    }
    
    func tileLeftThird() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX, y: f.minY, width: f.width / 3, height: f.height)
    }
    
    func tileCenterThird() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX + f.width / 3, y: f.minY, width: f.width / 3, height: f.height)
    }
    
    func tileRightThird() {
        guard let (window, screen) = getWindowAndScreen() else { return }
        let f = axVisibleFrame(for: screen)
        setWindowFrame(window, x: f.minX + (f.width / 3) * 2, y: f.minY, width: f.width / 3, height: f.height)
    }
    
    func moveToNextDisplay() {
        let screens = NSScreen.screens
        guard screens.count > 1 else { return }
        
        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef)
        guard result == .success, let windowValue = windowRef else { return }
        let window = windowValue as! AXUIElement
        
        guard let position = getWindowPosition(window),
              let size = getWindowSize(window) else { return }
        
        let currentScreen = screenForWindow(position: position, size: size)
        guard let currentIndex = screens.firstIndex(of: currentScreen) else { return }
        let nextScreen = screens[(currentIndex + 1) % screens.count]
        
        let currentVF = axVisibleFrame(for: currentScreen)
        let nextVF = axVisibleFrame(for: nextScreen)
        
        // Map position proportionally from current screen to next screen
        let relX = (position.x - currentVF.minX) / currentVF.width
        let relY = (position.y - currentVF.minY) / currentVF.height
        let relW = size.width / currentVF.width
        let relH = size.height / currentVF.height
        
        let newX = nextVF.minX + relX * nextVF.width
        let newY = nextVF.minY + relY * nextVF.height
        let newW = relW * nextVF.width
        let newH = relH * nextVF.height
        
        setWindowFrame(window, x: newX, y: newY, width: newW, height: newH)
    }
    
    // MARK: - Coordinate Conversion
    
    /// Returns the screen's visible frame converted to Accessibility API coordinates
    /// (origin at top-left of primary display, Y increases downward).
    private func axVisibleFrame(for screen: NSScreen) -> CGRect {
        guard let primaryScreen = NSScreen.screens.first else {
            return screen.visibleFrame
        }
        let primaryHeight = primaryScreen.frame.height
        let vf = screen.visibleFrame
        return CGRect(
            x: vf.origin.x,
            y: primaryHeight - vf.origin.y - vf.height,
            width: vf.width,
            height: vf.height
        )
    }
    
    // MARK: - Screen Detection
    
    /// Finds which screen contains the center of the given window.
    private func screenForWindow(position: CGPoint, size: CGSize) -> NSScreen {
        guard let primaryScreen = NSScreen.screens.first else {
            return NSScreen.main ?? NSScreen.screens[0]
        }
        let primaryHeight = primaryScreen.frame.height
        
        // Window center in AX coordinates
        let centerX = position.x + size.width / 2
        let centerYAX = position.y + size.height / 2
        
        // Convert to NSScreen coordinates (bottom-left origin, Y up)
        let centerYNS = primaryHeight - centerYAX
        let point = NSPoint(x: centerX, y: centerYNS)
        
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        
        // Fallback: find the closest screen by distance to center
        var bestScreen = NSScreen.main ?? NSScreen.screens[0]
        var bestDistance = CGFloat.greatestFiniteMagnitude
        for screen in NSScreen.screens {
            let screenCenter = NSPoint(
                x: screen.frame.midX,
                y: screen.frame.midY
            )
            let dx = point.x - screenCenter.x
            let dy = point.y - screenCenter.y
            let distance = dx * dx + dy * dy
            if distance < bestDistance {
                bestDistance = distance
                bestScreen = screen
            }
        }
        return bestScreen
    }
    
    // MARK: - Window Helpers
    
    private func getWindowAndScreen() -> (AXUIElement, NSScreen)? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        guard result == .success, let windowValue = windowRef else {
            return nil
        }
        
        let window = windowValue as! AXUIElement
        
        guard let position = getWindowPosition(window),
              let size = getWindowSize(window) else {
            let fallback = NSScreen.main ?? NSScreen.screens[0]
            return (window, fallback)
        }
        
        let screen = screenForWindow(position: position, size: size)
        return (window, screen)
    }
    
    private func getWindowSize(_ window: AXUIElement) -> CGSize? {
        var sizeRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        guard result == .success, let sizeValue = sizeRef else { return nil }
        
        var size = CGSize.zero
        AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        return size
    }
    
    private func getWindowPosition(_ window: AXUIElement) -> CGPoint? {
        var positionRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        guard result == .success, let positionValue = positionRef else { return nil }
        
        var position = CGPoint.zero
        AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        return position
    }
    
    private func setWindowPosition(_ window: AXUIElement, x: CGFloat, y: CGFloat) {
        var position = CGPoint(x: x, y: y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        }
    }
    
    private func setWindowFrame(_ window: AXUIElement, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        var position = CGPoint(x: x, y: y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        }
        
        var size = CGSize(width: width, height: height)
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}
