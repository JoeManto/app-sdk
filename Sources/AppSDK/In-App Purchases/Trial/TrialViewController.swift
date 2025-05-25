//
//  TrialViewController.swift
//
//
//  Created by Joe Manto on 4/24/23.
//

#if os(macOS)
import Foundation
import AppKit
import SwiftUI

public class TrialViewController: NSHostingController<TrialWallView> {
    
    public override init(rootView: TrialWallView) {
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension TrialViewController {
    
    func pushToWindow(title: String, display: Bool) -> NSWindow {
        let window = NSWindow(contentRect: NSRect(), styleMask: [.closable, .miniaturizable, .titled], backing: .buffered, defer: false)
        window.contentViewController = self
        window.isReleasedWhenClosed = true
        window.title = ""
        window.backgroundColor = NSColor.clear
        
        if display {
            window.makeKeyAndOrderFront(self)
        }
        
        return window
    }
}
#endif
