//
//  File.swift
//  
//
//  Created by Joe Manto on 4/24/23.
//

import AppKit
import Foundation
import Cocoa

public enum PaymentType {
    case yearly, monthy, onetime
}

public struct PaymentOption: Identifiable {
    public let id: UUID = UUID() // Change to in-app purchase id
    public let type: PaymentType
    public let price: Double
    public let recommended: Bool
    public let trialLength: Int
    
    public init(type: PaymentType, price: Double, recommended: Bool, trialLength: Int) {
        self.type = type
        self.price = price
        self.recommended = recommended
        self.trialLength = trialLength
    }
}

public struct TrialProduct {
    public let name: String
    public let options: [PaymentOption]
    public var image: NSImage? = nil
    
    public init(name: String, options: [PaymentOption], image: NSImage? = nil) {
        self.name = name
        self.options = options
        self.image = image
    }
}

public class TrialWallViewModel: ObservableObject {
    
    public var productModel: TrialProduct
    
    @Published public var selectedOption: PaymentOption?
    
    public init(productModel: TrialProduct) {
        self.productModel = productModel
        self.selectedOption = productModel.options.first
    }
    
    func paymentSelected(option: PaymentOption) {
        selectedOption = option
    }
    
    var trialTimelineNotification: String {
        if let option = self.selectedOption {
            if (option.trialLength - 2) == 1 {
                return "In \(option.trialLength - 2) Day"
            }
            else {
               return  "In \(option.trialLength - 2) Days"
            }
        }
        
        return ""
    }
    
    var trialTimelineEnd: String {
        if let option = self.selectedOption {
            if option.trialLength == 1 {
                return "In \(option.trialLength) Day"
            }
            else {
               return  "In \(option.trialLength) Days"
            }
        }
        
        return ""
    }
    
    var continueBtnTitle: String {
        if let option = self.selectedOption, option.type == .onetime {
            return "Continue"
        }
        else {
            return "Activate Free Trial"
        }
    }
}
