//
//  AppColors.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

struct DynamicColor {
    let normal: NSColor
    let highlight: NSColor
    
    func highlighting(_ isHighlighted: Bool) -> Color {
        if isHighlighted {
            return Color(highlight)
        }
        return Color(normal)
    }
}

struct AppColors {
    static let destructive = DynamicColor(normal: NSColor.hex("FF3B30", alpha: 1.0), highlight: NSColor.hex("FC5E56", alpha: 1.0))
    static let gray1 = DynamicColor(normal:  NSColor.hex("C7C7CC", alpha: 1.0), highlight: NSColor.hex("DEDEDE", alpha: 1.0))
}
