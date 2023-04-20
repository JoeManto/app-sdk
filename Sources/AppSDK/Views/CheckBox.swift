//
//  CheckBox.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

public struct CheckBox: View {
    public var isOn: Binding<Bool>
        
    private let onChange: ((Bool) -> Void)?
    private let allowUnchecking: Bool
    
    public init(isOn: Binding<Bool>, allowUnchecking: Bool = true, onChange: ((Bool) -> Void)? = nil) {
        self.isOn = isOn
        self.onChange = onChange
        self.allowUnchecking = allowUnchecking
    }
    
    public var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(NSColor.controlAccentColor))
                    .padding(2.5)
                    .opacity(isOn.wrappedValue ? 1.0 : 0.0)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !allowUnchecking, isOn.wrappedValue {
                return
            }
            
            isOn.wrappedValue = !isOn.wrappedValue
            self.onChange?(isOn.wrappedValue)
            
        }
        .frame(width: 15, height: 15)
    }
}

struct CheckBox_Previews: PreviewProvider {
   
    static var previews: some View {
        Group {
            CheckBox(isOn: Binding.constant(true))
                .padding()
        }
    }
}
