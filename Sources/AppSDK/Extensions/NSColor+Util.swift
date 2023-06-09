//
//  NSColor+Util.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import AppKit

public struct CodeableColor: Codable {
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    
    public var nsColor: NSColor {
        NSColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
    
    public init(from color: NSColor) {
        var comps = [CGFloat](repeating: 0.0, count: color.numberOfComponents)
        color.getComponents(&comps)
    
        self.red = comps[0]
        self.green = comps[1]
        self.blue = comps[2]
        self.alpha = comps[3]
    }
}

public extension NSColor {
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    static func hex(_ str: String, alpha: CGFloat) -> NSColor {
        let hexString = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension NSColor {
    
    static let backgroundPrimary = NSColor(light: .white, dark: .black)
    static let textColorPrimary = NSColor(light: .black, dark: .white)
    static let secondaryTextColor = NSColor.lightGray
    static let addressBarBackground = NSColor.lightGray
    
    convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil, dynamicProvider: { appearance in
            if UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" {
                return dark
            }
            return light
        })
    }
}
