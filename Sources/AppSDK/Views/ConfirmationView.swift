//
//  ConfirmationView.swift
//  
//
//  Created by Joe Manto on 5/5/23.
//

#if os(macOS)
import Foundation
import SwiftUI
import AppKit

public struct Confirmation {
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

public class ConfirmationViewModel {
    public var onContinue: (() -> Void)?
    public var onCancel: (() -> Void)?
    
    public let confirmation: Confirmation
    
    public init(confirmation: Confirmation, onContinue: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.onContinue = onContinue
        self.onCancel = onCancel
        self.confirmation = confirmation
    }
    
    public func continueTapped() {
        self.onContinue?()
    }
    
    public func cancelTapped() {
        self.onCancel?()
    }
}

public struct ConfirmationView: View {
    
    public let vm: ConfirmationViewModel
    
    public init(vm: ConfirmationViewModel) {
        self.vm = vm
    }
    
    public var body: some View {
        VStack {
            Text(vm.confirmation.title)
                .font(.standardFontMedium(size: 18, relativeTo: .title))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing, .top])
            
            if !vm.confirmation.subtitle.isEmpty {
                Text(vm.confirmation.subtitle)
                    .font(.standardFont(size: 12, relativeTo: .subheadline))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing])
            }
            
            HStack {
                Button("Cancel", action: vm.cancelTapped)
                Spacer()
                Button("Continue", action: vm.continueTapped)
            }
            .padding()
        }
        .fixedSize()
    }
}

public class ConfirmationViewController: NSHostingController<ConfirmationView> {
        
    public init(confirm: Confirmation, onContinue: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        let vm = ConfirmationViewModel(confirmation: confirm)
        let view = ConfirmationView(vm: vm)
        super.init(rootView: view)
        
        vm.onContinue = {
            self.remove()
            onContinue?()
        }
        
        vm.onCancel = {
            self.remove()
            onCancel?()
        }
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func remove() {
        if let window = self.view.window {
            WindowManager.shared.remove(window: window)
        }
    }
    
    public func pushToWindow() {
        let window = WindowManager.shared.create(root: self, shouldShow: true, style: [.closable, .titled])
        window.level = .floating
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(vm: ConfirmationViewModel(confirmation: Confirmation(title: "Title", subtitle: "Subtitle")))
    }
}
#endif
