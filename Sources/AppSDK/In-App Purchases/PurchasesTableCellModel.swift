//
//  PurchasesTableCellModel.swift
//  SuperWindow
//
//  Created by Joe Manto on 9/26/21.
//

#if os(macOS)
import Foundation
import StoreKit

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

struct PurchasesTableCellModel {
    var product: SKProduct
    var isPurchased: Bool
    
    func getProductTitle() -> String {
        var title = self.product.localizedTitle
        let productPriceString = self.getProductPrice()
        
        return "\(title) - \(productPriceString)"
    }
    
    func getProductSubtitle() -> String {
        let subTitle = self.product.localizedDescription        
        return subTitle
    }
    
    func getProductPrice() -> String {        
        if let price = self.product.regularPrice {
            return price
        }
        
        let localSymbol: String = {
            guard let symbol = self.product.priceLocale.currencySymbol else {
                Logging.shared.log(msg: "No price locale defaulting to USD")
                AppSDKUtil.showStoreKitAlert(title: "Locale Not Found", msg: "No price locale found - Showing prices in USD")
                return "$"
            }
            return symbol
        }()
        let priceString = self.product.price.description(withLocale: self.product.priceLocale)
        
        return "\(localSymbol)\(priceString)"
    }
}
#endif
