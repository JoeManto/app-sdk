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
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(in: CoordinateSpace.global)
                        }
                }
            )
    }
}

extension View {
    func readFrame(_ frame: Binding<CGRect>) -> some View {
        return self.modifier(ReadFrameModifier(frame: frame))
    }
}
