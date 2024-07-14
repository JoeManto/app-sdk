//
//  Transitions.swift
//
//
//  Created by Joe Manto on 7/13/24.
//

import SwiftUI

extension AnyTransition {
    static func backslide(offset: CGSize) -> AnyTransition {
        return AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .trailing).combined(with: .offset(offset))
        )
    }
}
