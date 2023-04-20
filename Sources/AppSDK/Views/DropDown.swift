//
//  DropDown.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

public struct DropDownView: View {
    
    public let title: String
    public let items: [String]
    public let onSelection: (Int, String) -> ()
    
    public var body: some View {
        Menu {
            ForEach((0..<items.count), id: \.self) { i in
                Button(items[i], action: {
                    onSelection(i, items[i])
                })
                Divider()
            }
        } label: {
            Text(title)
        }
    }
}
