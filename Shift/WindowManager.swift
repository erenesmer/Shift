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
        print("Tiling LEFT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Left half: x=0, y=menuBar, width=half, height=full
        let x = frame.origin.x
        let y = menuBarHeight
        let width = frame.width / 2
        let height = frame.height
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileRight() {
        print("Tiling RIGHT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Right half: x=half, y=menuBar, width=half, height=full
        let x = frame.origin.x + frame.width / 2
        let y = menuBarHeight
        let width = frame.width / 2
        let height = frame.height
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileTop() {
        print("Tiling TOP...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Top half: x=0, y=menuBar, width=full, height=half
        let x = frame.origin.x
        let y = menuBarHeight
        let width = frame.width
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileBottom() {
        print("Tiling BOTTOM...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Bottom half: x=0, y=menuBar+halfHeight, width=full, height=half
        let x = frame.origin.x
        let y = menuBarHeight + frame.height / 2
        let width = frame.width
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func maximize() {
        print("MAXIMIZING...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Full screen (visible area)
        let x = frame.origin.x
        let y = menuBarHeight
        let width = frame.width
        let height = frame.height
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func center() {
        print("CENTERING...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        // Get current window size
        guard let currentSize = getWindowSize(window) else {
            print("ERROR: Could not get window size")
            return
        }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        // Keep current size, just center position
        let x = frame.origin.x + (frame.width - currentSize.width) / 2
        let y = menuBarHeight + (frame.height - currentSize.height) / 2
        
        // Only set position, not size
        setWindowPosition(window, x: x, y: y)
        print("Centered to: x=\(x), y=\(y) (size unchanged: \(currentSize.width)x\(currentSize.height))")
    }
    
    func increaseSize() {
        print("INCREASING SIZE...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        guard let currentSize = getWindowSize(window) else {
            print("ERROR: Could not get window size")
            return
        }
        
        guard let currentPosition = getWindowPosition(window) else {
            print("ERROR: Could not get window position")
            return
        }
        
        let frame = screen.visibleFrame
        
        // Increase by 10%
        let increaseAmount: CGFloat = 0.1
        let newWidth = min(currentSize.width * (1 + increaseAmount), frame.width)
        let newHeight = min(currentSize.height * (1 + increaseAmount), frame.height)
        
        // Adjust position to keep window centered during resize
        let deltaWidth = newWidth - currentSize.width
        let deltaHeight = newHeight - currentSize.height
        let newX = max(frame.origin.x, currentPosition.x - deltaWidth / 2)
        let newY = max(0, currentPosition.y - deltaHeight / 2)
        
        setWindowFrame(window, x: newX, y: newY, width: newWidth, height: newHeight)
        print("Increased to: \(newWidth)x\(newHeight)")
    }
    
    func decreaseSize() {
        print("DECREASING SIZE...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        guard let currentSize = getWindowSize(window) else {
            print("ERROR: Could not get window size")
            return
        }
        
        guard let currentPosition = getWindowPosition(window) else {
            print("ERROR: Could not get window position")
            return
        }
        
        // Decrease by 10%, but keep minimum size
        let decreaseAmount: CGFloat = 0.1
        let minSize: CGFloat = 200
        let newWidth = max(currentSize.width * (1 - decreaseAmount), minSize)
        let newHeight = max(currentSize.height * (1 - decreaseAmount), minSize)
        
        // Adjust position to keep window centered during resize
        let deltaWidth = currentSize.width - newWidth
        let deltaHeight = currentSize.height - newHeight
        let newX = currentPosition.x + deltaWidth / 2
        let newY = currentPosition.y + deltaHeight / 2
        
        setWindowFrame(window, x: newX, y: newY, width: newWidth, height: newHeight)
        print("Decreased to: \(newWidth)x\(newHeight)")
    }
    
    func tileTopLeft() {
        print("Tiling TOP LEFT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        let x = frame.origin.x
        let y = menuBarHeight
        let width = frame.width / 2
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileTopRight() {
        print("Tiling TOP RIGHT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        let x = frame.origin.x + frame.width / 2
        let y = menuBarHeight
        let width = frame.width / 2
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileBottomLeft() {
        print("Tiling BOTTOM LEFT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        let x = frame.origin.x
        let y = menuBarHeight + frame.height / 2
        let width = frame.width / 2
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    func tileBottomRight() {
        print("Tiling BOTTOM RIGHT...")
        guard let (window, screen) = getWindowAndScreen() else { return }
        
        let frame = screen.visibleFrame
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height - screen.visibleFrame.origin.y
        
        let x = frame.origin.x + frame.width / 2
        let y = menuBarHeight + frame.height / 2
        let width = frame.width / 2
        let height = frame.height / 2
        
        setWindowFrame(window, x: x, y: y, width: width, height: height)
        print("Set to: x=\(x), y=\(y), width=\(width), height=\(height)")
    }
    
    // MARK: - Private Methods
    
    private func getWindowAndScreen() -> (AXUIElement, NSScreen)? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            print("ERROR: No frontmost application")
            return nil
        }
        
        print("Frontmost app: \(app.localizedName ?? "Unknown")")
        
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        guard result == .success, let windowValue = windowRef else {
            print("ERROR: Could not get focused window. Error: \(result.rawValue)")
            return nil
        }
        
        let window = windowValue as! AXUIElement
        
        guard let screen = NSScreen.main else {
            print("ERROR: No main screen")
            return nil
        }
        
        print("Screen: \(screen.frame), visible: \(screen.visibleFrame)")
        
        return (window, screen)
    }
    
    private func getWindowSize(_ window: AXUIElement) -> CGSize? {
        var sizeRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        
        guard result == .success, let sizeValue = sizeRef else {
            return nil
        }
        
        var size = CGSize.zero
        AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        return size
    }
    
    private func getWindowPosition(_ window: AXUIElement) -> CGPoint? {
        var positionRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        
        guard result == .success, let positionValue = positionRef else {
            return nil
        }
        
        var position = CGPoint.zero
        AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        return position
    }
    
    private func setWindowPosition(_ window: AXUIElement, x: CGFloat, y: CGFloat) {
        var position = CGPoint(x: x, y: y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            let posResult = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
            print("Position set result: \(posResult == .success ? "OK" : "FAILED (\(posResult.rawValue))")")
        }
    }
    
    private func setWindowFrame(_ window: AXUIElement, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        // Set position
        var position = CGPoint(x: x, y: y)
        if let positionValue = AXValueCreate(.cgPoint, &position) {
            let posResult = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
            print("Position set result: \(posResult == .success ? "OK" : "FAILED (\(posResult.rawValue))")")
        }
        
        // Set size
        var size = CGSize(width: width, height: height)
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            let sizeResult = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
            print("Size set result: \(sizeResult == .success ? "OK" : "FAILED (\(sizeResult.rawValue))")")
        }
    }
}
