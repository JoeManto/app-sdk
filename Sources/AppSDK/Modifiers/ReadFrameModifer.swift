//
//  File.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

private struct ReadFrameModifier: ViewModifier {
    
    @Binding var frame: CGRect
    
    let space: CoordinateSpace
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(in: space)
                        }
                }
            )
    }
}

public extension View {
    func readFrame(_ frame: Binding<CGRect>, space: CoordinateSpace = .global) -> some View {
        return self.modifier(ReadFrameModifier(frame: frame, space: space))
    }
}
