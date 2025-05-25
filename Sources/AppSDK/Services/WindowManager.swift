//
//  WindowManager.swift
//  
//
//  Created by Joe Manto on 5/5/23.
//

#if os(macOS)
import Foundation
import AppKit

public class WindowManager {
    public static let shared = WindowManager()
    
    public internal(set) var activeWindows: [String : NSWindowController] = [:]
    
    /// The number of windows added in total
    /// This number doesn't decrease as windows are removed
    /// Ensures every new window will have a unique window Id
    public internal(set) var uniqueId: UInt = 0
        
    internal init() {}
    
    /// Creates a new window and adds as managed window
    @discardableResult public func create(
        root: NSViewController,
        shouldShow: Bool = true,
        style: NSWindow.StyleMask = [],
        delegate: NSWindowDelegate? = nil
        
    ) -> NSWindow {
        let window = self.create(delegate: delegate, root: root)
        window.styleMask = style
        let id = window.identifier!.rawValue
        
        _ = self.add(window)
        Logging.shared.log(msg: "Window created with id: \(id)")
        
        if (shouldShow) {
            self.show(window)
        }
        
        return window
    }
    
    /// Wraps a custom window in controller and appends to manager. If the window doesn't have an identifier or the identifer
    /// is already taken the window is assigned a new identifer.
    /// This new identifer is returned in such cases otherwise nil
    public func add(_ window: NSWindow) -> String? {
        var override: String?
        let windowId: String!
        
        if let id = window.identifier?.rawValue {
            windowId = id
        }
        else {
            override = self.newId()
            windowId = override
            window.identifier = NSUserInterfaceItemIdentifier(windowId)
        }
        
        let windowController = NSWindowController(window: window)
        self.activeWindows[windowId] = windowController
        return override
    }
    
    /// Removes a given window from the manager
    public func remove(with id: String) {
        self.activeWindows[id]?.window?.close()
        self.activeWindows[id]?.close()
        self.activeWindows.removeValue(forKey: id)
    }
    
    /// Removes a given window from the manager
    /// Closes the window if not managed
    public func remove(window: NSWindow) {
        if let id = window.identifier?.rawValue {
            self.remove(with: id)
        }
        else {
            window.close()
        }
    }
    
    /// Removes key window if present in active manged windows
    public func removeKeyWindow() {
        Logging.shared.log(msg: "Removing Key Window")
        guard let keyWindow = self.getKeyWindow() else {
            return
        }
        self.remove(window: keyWindow)
    }
    
    /// Returns the key window from all active managed windows
    public func getKeyWindow() -> NSWindow? {
        for key in Array(self.activeWindows.keys) {
            guard let window = self.activeWindows[key]?.window else {
                continue
            }
            
            if window.isKeyWindow {
                return window
            }
        }
        
        Logging.shared.log(msg: "No key window found")
        return nil
    }
    
    /// Orders the showing of the window with given id
    public func show(_ id: String) {
        guard let window = self.activeWindows[id]?.window else {
            Logging.shared.log(msg: "Must have controller for id: \(id) or window controller must have window")
            return
        }
        self.show(window)
    }
    
    /// Orders the showing of the window managed or not
    public func showWindow(_ window: NSWindow) {
        if let id = window.identifier?.rawValue {
            self.show(id)
        }
        else {
            window.makeKeyAndOrderFront(self)
        }
    }
    
    private func create(delegate: NSWindowDelegate?, root: NSViewController) -> NSWindow {
        let window = NSWindow()
        let id = self.newId()
        
        if let delegate = delegate {
            window.delegate = delegate
        }
        else {
            Logging.shared.log(msg: "Warning no delegate on new window with id: \(id)")
        }
        window.contentViewController = root
        window.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
        return window
    }

    private func show(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            Logging.shared.log(msg: "Window must have an id \(#function)")
            return
        }
        window.makeKeyAndOrderFront(self.activeWindows[id])
    }
    
    private func newId() -> String {
        let id = "WINDOW_\(self.uniqueId)"
        self.uniqueId += 1
        return id
    }
}
#endif
