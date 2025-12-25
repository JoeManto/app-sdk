//
//  CLIProperties.swift
//  PrefCLI
//
//  Created by Joe Manto on 12/19/25.
//

import AppSDK
import Darwin
import Foundation

public struct CLIProperties {
    public static var shared = CLIProperties()

    public var displayWidth: Int {
        return Int(displaySize.width)
    }

    public var displayHeight: Int {
        return Int(displaySize.height)
    }

    public var displaySize: NSSize {
        var windowSize = winsize()
        // STDOUT_FILENO is the file descriptor for standard output
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &windowSize) == 0 {
            return NSSize(width: CGFloat(windowSize.ws_col), height: CGFloat(windowSize.ws_row))
        } else {
            return NSSize(width: 100.0, height: CGFloat(Float.infinity))
        }
    }
}
