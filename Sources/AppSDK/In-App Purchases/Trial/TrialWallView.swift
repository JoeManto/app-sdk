//
//  TrialWallActionHandler.swift
//
//
//  Created by Joe Manto on 4/24/23.
//

import Foundation
import SwiftUI

#if os(macOS)
public class TrialWallActionHandler {
    public let onRestore: () -> Void
    public let onTerms: () -> Void
    public let onContinue: (PaymentOption) -> Void
    
    public init(onRestore: @escaping () -> Void,
         onTerms: @escaping () -> Void,
         onContinue: @escaping (PaymentOption) -> Void) {
        self.onRestore = onRestore
        self.onTerms = onTerms
        self.onContinue = onContinue
    }
}

public struct TrialWallView: View {
    
    @ObservedObject public var vm: TrialWallViewModel
        
    public var headerView: (AnyView)? = nil
    
    public let actionHandler: TrialWallActionHandler
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    public init(vm: TrialWallViewModel, headerView: AnyView? = nil, actionHandler: TrialWallActionHandler) {
        self.vm = vm
        self.headerView = headerView
        self.actionHandler = actionHandler
    }

    public var body: some View {
        ScrollView {
            VStack {
                if let headerView = headerView {
                    headerView
                }
                else {
                    self.defaultHeader()
                }
                
                ForEach(vm.productModel.options, id: \.type) { option in
                    PaymentOptionView(vm: PaymentOptionViewModel(option: option, onPaymentSelect: {
                        vm.paymentSelected(option: option)
                    }), selected: vm.selectedOption?.id == option.id)
                }
                
                restoreAndTerms()
                
                VStack {
                    Text("Free Trial Timeline")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.standardFontBold(size: 18, relativeTo: .title))
                        .padding(.bottom, 10)
                    
                    timelineDay(
                        imgName: "circle.circle.fill",
                        title: "Today",
                        subtitle: "Start using One Palette for free", idx: 0
                    )
                    .padding(.bottom, 8)
                    
                    timelineDay(
                        imgName: "bell.circle",
                        title: vm.trialTimelineNotification,
                        subtitle: "You recive a notification about\n your free trial ending soon", idx: 1
                    )
                    .padding(.bottom, 8)
                    
                    timelineDay(
                        imgName: "circle",
                        title: vm.trialTimelineEnd,
                        subtitle: """
                Your tiral ends and automatically
                resubsribes if your subscription is active
                
                Subscriptions can be cancelled anytime
                by managing your subscriptions
                """, idx: 2
                    )
                }
                .frame(width: 325)
                .padding(.top, 25)
                
                continueBtn()
                    .padding(.top, 50)
            }
            .padding([.leading, .trailing], 50)
            .padding([.top, .bottom])
        }
        .background(colorScheme == ColorScheme.dark ? Color.black : Color.white)
        .frame(width: 400, height: 700)
    }
    
    @ViewBuilder func timelineDay(imgName: String, title: String, subtitle: String, idx: Int) -> some View {
        HStack {
            HStack {
                VStack {
                    if idx == 0 {
                        Image(systemName: imgName)
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    else {
                        Image(systemName: imgName)
                            .font(.system(size: 18))
                    }
   
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Text(title)
                            .font(.standardFontBold(size: 18, relativeTo: .title))
                        Spacer()
                    }
                    HStack {
                        Text(subtitle)
                            .font(.standardFont(size: 12, relativeTo: .title))
                        
                        Spacer()
                    }
                }
                Spacer()
            }
            .fixedSize()
            Spacer()
        }
    }
    
    @ViewBuilder func continueBtn() -> some View {
        Text("Activate Free Trial")
            .font(.standardFontBold(size: 18, relativeTo: .body))
            .foregroundColor(.white)
            .padding(10)
            .background(.blue)
            .cornerRadius(18)
    }
    
    @ViewBuilder func restoreAndTerms() -> some View {
        HStack {
            Text("Restore Purchases")
                .font(.standardFontMedium(size: 10, relativeTo: .body))
                .foregroundColor(.blue)
               
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
            
            Text("Terms and Conditions")
                .font(.standardFontMedium(size: 10, relativeTo: .body))
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder func defaultHeader() -> some View {
        VStack {
            if /*let img = vm.productModel.image*/ true {
                Image("example-product-img", bundle: Bundle.module)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(10)
                    .clipShape(Circle())
            }
            
            Text("One Palette Trial")
                .font(.standardFontBold(size: 18, relativeTo: .title))
        }
    }
}

struct TrialWallView_Previews: PreviewProvider {
    static var previews: some View {
        TrialWallView(vm: TrialWallViewModel(productModel: TrialProduct(name: "One Palette Trial", options: [
            PaymentOption(type: .yearly, price: 9.99, recommended: true, trialLength: 7),
            PaymentOption(type: .monthy, price: 2.99, recommended: false, trialLength: 7),
            PaymentOption(type: .onetime, price: 24.99, recommended: false, trialLength: 7)
        ])), actionHandler: TrialWallActionHandler(onRestore: {}, onTerms: {}, onContinue: { _ in }))
    }
}

/*
 ZStack {
     Image("example-product-img", bundle: Bundle.module)
         .frame(width: 100, height: 100)
     
     Text("One Palette Trial")
         .font(.standardFontBold(size: 24, relativeTo: .title))
         .padding(10)
         .background(Environment(\.colorScheme).wrappedValue == ColorScheme.dark ? Color.white : Color.black)
         .cornerRadius(20)
 }
 */
#endif
