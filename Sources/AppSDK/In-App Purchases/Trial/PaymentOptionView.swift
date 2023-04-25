//
//  File.swift
//  
//
//  Created by Joe Manto on 4/24/23.
//

import Foundation
import SwiftUI

public class PaymentOptionViewModel {
    public let option: PaymentOption
    public var onPaymentSelect: (() -> Void)?
    
    var title: String {
        switch option.type {
        case .yearly:
            return String(format: "$%.2f Annual", option.price)
        case .monthy:
            return String(format: "$%.2f Monthly", option.price)
        case .onetime:
            return String(format: "$%.2f", option.price)
        }
    }
    
    var annualCostMonthlyTitle: String {
        String(format: "($%.2f Month)", option.price / 12)
    }
    
    var freeTrailDays: String {
        if option.type == .onetime {
           return "One Time Purchase"
        }
        else {
           return "\(option.trialLength) Days Free"
        }
    }
    
    public init(option: PaymentOption, onPaymentSelect: (() -> Void)? = nil) {
        self.option = option
        self.onPaymentSelect = onPaymentSelect
    }
}

struct PaymentOptionView: View {
    
    let vm: PaymentOptionViewModel
    
    var selected: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(vm.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.standardFontBold(size: 18, relativeTo: .body))
                    
                    if vm.option.recommended {
                        Spacer()
                    
                        Text("Best Value")
                            .font(.standardFontMedium(size: 10, relativeTo: .body))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(.blue)
                            .cornerRadius(8)
                    }
                }
                
                if vm.option.type == .yearly {
                    Text(vm.annualCostMonthlyTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                        .foregroundColor(.green)
                }
                
                Text(vm.freeTrailDays)
                    .padding(.top, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                
            }
            .frame(width: 300)
            .padding()
            .background(colorScheme == ColorScheme.dark ? Color.black : Color.white)
            .cornerRadius(12)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 5)
                    .background(.clear)
                    .cornerRadius(12)
            })
        }
        .padding(8)
        .overlay(content: {
            if selected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 5)
                    .background(.clear)
                    .cornerRadius(12)
            }
        })
        .onTapGesture {
            vm.onPaymentSelect?()
        }
    }
}

struct PaymentOptionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaymentOptionView(vm: PaymentOptionViewModel(option: PaymentOption(type: .yearly, price: 9.99, recommended: true, trialLength: 7), onPaymentSelect: {}))
                .padding()
            PaymentOptionView(vm: PaymentOptionViewModel(option:
                            PaymentOption(
                                type: .yearly,
                                price: 9.99,
                                recommended: true,
                                trialLength: 7
                            ), onPaymentSelect: {}), selected: true)
                .padding()
        }
    }
}
