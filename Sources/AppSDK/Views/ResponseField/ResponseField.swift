//
//  ResponseField.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI

public struct ResponseField: View {
    public let vm: ResponseFieldViewModel
    
    @State public var selection: String
    @State private var actionInProgress: Bool = false
    
    @State private var btnSize = CGSize(width: 0, height: 0)
    @State private var offsetX = 0.0
    @State private var deleting = false
    
    @State private var waveIndicatorScale = 1.0
    @State private var waveIndicatorOpacity = 0.0
    
    public init(vm: ResponseFieldViewModel) {
        self.vm = vm
        
        if let selectionContent = vm.content as? ResponseFieldSelection {
            self.selection = selectionContent.options.first ?? ""
        } else {
            self.selection = ""
        }
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text(vm.content.name)
                    .font(Font.standardFontMedium(size: 14, relativeTo: .body))
                Spacer()
            
                inputView()
                    .padding(.top, 8)
                    .fixedSize()
            }
            .padding([.bottom], 3)
            
            HStack {
                Text(vm.content.subtitle)
                    .font(Font.standardFontMedium(size: 14, relativeTo: .body))
                    .foregroundColor(.gray)
                    .frame(maxWidth: 400, alignment: .leading)
                Spacer()
            }
        }
    }

    private func inputView() -> some View {
        VStack {
            if let selectionContent = vm.content as? ResponseFieldSelection {
                self.selectionView(selectionContent: selectionContent)
            }
            else if let actionContent = vm.content as? ResponseFieldAction {
                self.actionView(action: actionContent)
            }
        }
    }
    
    func deletionAnimation(duration: Int) {
        var transaction = Transaction(animation: .linear)
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            self.offsetX = self.btnSize.width
            withAnimation(.linear(duration: Double(duration))) {
                self.offsetX = 0
            }
        }
    }
    
    func deletionCompleteAnimation() {
        self.waveIndicatorOpacity = 1.0
        withAnimation(.easeInOut(duration: 1.0)) {
            self.waveIndicatorScale = 1.5
            self.waveIndicatorOpacity = 0.0
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
                self.waveIndicatorOpacity = 0.0
                self.waveIndicatorScale = 1.0
            }
        }
    }
    
    @ViewBuilder private func actionView(action: ResponseFieldAction) -> some View {
        VStack {
            ZStack {
                Color.red
                    .opacity(1.0)
                    .cornerRadius(8)
                    .offset(x: offsetX)
                
                Text(action.btnTitle)
                    .foregroundColor({
                        if action.destructive {
                            return deleting ? .white : AppColors.destructive.highlighting(actionInProgress)
                        }
                        else {
                            return AppColors.gray1.highlighting(actionInProgress)
                        }
                    }())
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 10)
                    
            }
            .cornerRadius(8)
            .readIntrinsicContentSize(to: $btnSize)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke({ () -> Color in
                        if action.destructive {
                            return AppColors.destructive.highlighting(actionInProgress)
                        }
                        else {
                            return AppColors.gray1.highlighting(actionInProgress)
                        }
                    }(), lineWidth: 1.5)
                    
            )
            .onHold(
                onTap: {
                    print("onTap")
                    if action.destructive, self.deleting == false {
                        self.deleting = true
                        
                        deletionAnimation(duration: action.dur)
                    }
                },
                onRelease: { time in
                    guard action.destructive else {
                        action.onAction?()
                        return
                    }
                    
                    self.deleting = false
                    self.offsetX = self.btnSize.width
                    
                    if time >= Double(action.dur) {
                        action.onAction?()
                        deletionCompleteAnimation()
                    }
                },
                maxHoldTime: action.dur
            )
            .onAppear {
                self.offsetX = self.btnSize.width
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.destructive.highlighting(false), lineWidth: 1.0)
                .scaleEffect(self.waveIndicatorScale)
                .opacity(self.waveIndicatorOpacity)
        }
    }
    
    private func selectionView(selectionContent: ResponseFieldSelection) -> some View {
        VStack {
            DropDownView(title: selection, items: selectionContent.options, onSelection: { i, newSelection in
                selection = newSelection
                selectionContent.onSelection?(i, newSelection)
            })
            .fixedSize()
            Spacer()
        }
    }
}

struct ResponseField_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldAction(name: "Sort palette by brightness", btnTitle: "Sort", subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group")))
            
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldAction(name: "Delete palette", btnTitle: "delete", subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group", destructive: true)))
            
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldSelection(name: "Selection Title", subtitle: "Selection Subtitle", options: ["Option 1", "Option 2", "Option 3"])))
    
        }
        .padding(50)
    }
}
