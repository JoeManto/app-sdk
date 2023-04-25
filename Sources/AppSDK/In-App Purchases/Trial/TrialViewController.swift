//
//  File.swift
//  
//
//  Created by Joe Manto on 4/24/23.
//

import Foundation
import AppKit
import SwiftUI

public class TrialViewController: NSHostingController<TrialWallView> {
    public override init?(coder: NSCoder, rootView: TrialWallView) {
        super.init(coder: coder, rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension TrialViewController {
    
    func pushToWindow() -> NSWindow {
        let window = NSWindow(contentRect: NSRect(), styleMask: .closable, backing: .buffered, defer: false)
        window.contentViewController = self
        window.makeKeyAndOrderFront(self)
        
        return window
    }
}
