//
//  Font+Standard.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

public extension Font {
    static func standardFont(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next", size: size, relativeTo: relativeTo)
    }
    
    static func standardFontMedium(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next Medium", size: size, relativeTo: relativeTo)
    }
    
    static func standardFontBold(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next Bold", size: size, relativeTo: relativeTo)
    }
}
