//
//  CLIProperties.swift
//  PrefCLI
//
//  Created by Joe Manto on 12/19/25.
//

import AppSDK
import Darwin
import Foundation

struct CLIProperties {
    static var shared = CLIProperties()

    var displayWidth: Int {
        return Int(displaySize.width)
    }

    var displayHeight: Int {
        return Int(displaySize.height)
    }

    var displaySize: NSSize {
        var windowSize = winsize()
        // STDOUT_FILENO is the file descriptor for standard output
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &windowSize) == 0 {
            return NSSize(width: CGFloat(windowSize.ws_col), height: CGFloat(windowSize.ws_row))
        } else {
            return NSSize(width: 100.0, height: CGFloat(Float.infinity))
        }
    }
}
