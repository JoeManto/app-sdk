//
//  NSWindow+Moving.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import AppKit

public extension NSWindow {
    
    enum WindowLocation {
        case TopRight, TopLeft, BottomRight, BottomLeft, center
    }
    
    func moveTopRightRepeatedly() {
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
    
    func moveWindow(location: WindowLocation) {
        Logging.shared.log(msg: "Moving Window \(self.identifier?.rawValue ?? "nil") to \(location)", comp: "[WindowUtil]")
        switch location {
        case .TopRight:
            self.moveWindowTopRight()
            break
        case .TopLeft:
            self.moveWindowTopLeft()
            break
        case .BottomLeft:
            self.moveWindowBottomLeft()
            break
        case .BottomRight:
            self.moveWindowBottomRight()
            break
        case .center:
            self.moveWindowCenter()
        }
    }
    
    private func moveWindowTopRight() {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = self.frame
        
        let xPosition = screen.width - windowFrame.width
        let yPosition = screen.height - windowFrame.height
        self.setFrameOrigin(CGPoint(x: xPosition, y: yPosition))
    }
    
    private func moveWindowTopLeft() {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = self.frame
        
        let yPosition = screen.height - windowFrame.height
        self.setFrameOrigin(CGPoint(x: 0, y: yPosition))
    }
    
    private func moveWindowBottomLeft() {
        self.setFrameOrigin(CGPoint(x: 0, y: 0))
    }
    
    private func moveWindowBottomRight() {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = self.frame
        
        let xPosition = screen.width - windowFrame.width
        self.setFrameOrigin(CGPoint(x: xPosition, y: 0))
    }
    
    private func moveWindowCenter() {
        guard let screen = self.screen ?? NSScreen.main else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = self.frame
        
        let xPosition = screen.frame.width - windowFrame.width
        let yPosition = screen.frame.height - windowFrame.height
        self.setFrameOrigin(CGPoint(x: xPosition / 2, y: yPosition / 2))
    }
}
