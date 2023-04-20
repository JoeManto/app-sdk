//
//  DropDown.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

struct DropDownView: View {
    
    let title: String
    let items: [String]
    let onSelection: (Int, String) -> ()
    
    var body: some View {
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
