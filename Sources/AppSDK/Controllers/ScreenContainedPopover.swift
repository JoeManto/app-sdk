//
//  ScreenContainedPopover.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

#if os(macOS)
import Foundation
import AppKit

public class ScreenContainedPopover: NSPopover {
    
    private var showingObserver: NSKeyValueObservation?
    private var windowFrameObserver: NSKeyValueObservation?
    
    public var startingOrigin: NSPoint?
    
    public override init() {
        super.init()
        
        self.showingObserver = self.observe(\.isShown, changeHandler: { [unowned self] (_,_) in
            self.handleShowingChange()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetPopoverOrigin() {
        if let origin = startingOrigin {
            self.window?.setFrameOrigin(origin)
        }
        
        if self.isShown {
            self.window?.moveTopRightRepeatedly()
        }
    }
    
    public func handleShowingChange() {
        if self.isShown {
            self.window?.moveTopRightRepeatedly()
        }
        else {
            resetPopoverOrigin()
        }
    }
    
    public func showNear(statusItem: NSStatusItem) {
        let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
        invisibleWindow.backgroundColor = .red
        invisibleWindow.alphaValue = 0
        
        if let button = statusItem.button {
            let buttonRect:NSRect = button.convert(button.bounds, to: nil)
            let screenRect:NSRect = button.window!.convertToScreen(buttonRect)
            
            // calculate the bottom center position (10 is the half of the window width)
            let posX = screenRect.origin.x + (screenRect.width / 2) - 10
            let posY = screenRect.origin.y

            // position and show the window
            invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
            invisibleWindow.makeKeyAndOrderFront(self)
            
            self.startingOrigin = invisibleWindow.frame.origin
            self.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: NSRectEdge.minY)
            
            self.contentViewController?.view.window?.makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

public extension NSPopover {
    var window: NSWindow? {
        self.contentViewController?.view.window
    }
}
#endif
