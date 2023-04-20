//
//  NSWindow+Moving.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import AppKit

extension NSWindow {
    func moveTopRight() {
        // Attempt to the position the window 5 times over a 250 millisecond period
        for update in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(update * 50))) {
                guard let screen = NSScreen.main?.frame else {
                    return
                }
                
                let xPosition = screen.width - self.frame.width
                let yPosition = screen.height - self.frame.height
                let origin = CGPoint(x: xPosition, y: yPosition)
                
                self.setFrameOrigin(origin)
            }
        }
    }
}
