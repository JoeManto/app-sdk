//
//  EditableLabel.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation
import SwiftUI
import Combine

extension View {
    @ViewBuilder
    private func onBackgroundTapContent(enabled: Bool, viewFrame: CGRect, windowSize: CGSize, _ action: @escaping () -> Void) -> some View {
        if enabled {
            Color.clear
                .frame(width: windowSize.width, height: windowSize.height)
                .contentShape(Rectangle())
                .onTapGesture(count: 1, coordinateSpace: .global, perform: { tapLocation in
                    if !viewFrame.contains(tapLocation) {
                        action()
                    }
                })
        }
    }

    func onBackgroundTap(enabled: Bool, windowSize: CGSize, viewFrame: CGRect, _ action: @escaping () -> Void) -> some View {
        return background(
            onBackgroundTapContent(enabled: enabled, viewFrame: viewFrame, windowSize: windowSize, action)
        )
    }
}

struct EditableLabel: View {
    @Binding var text: String
        
    @State var editing = false {
        didSet {
            if text.isEmpty {
                text = "Empty"
            }
            
            guard !editing else {
                return
            }
        }
    }
    
    @State var frame: CGRect = .zero
    
    let onEditEnd: () -> Void
    
    let containingWindowSize: CGSize
    
    init(_ txt: Binding<String>, containingWindow: NSWindow, onEditEnd: @escaping () -> Void) {
        _text = txt
        self.onEditEnd = onEditEnd
        self.containingWindowSize = containingWindow.contentView?.bounds.size ?? .zero
    }
    
    var body: some View {
        
        ZStack {
            textFieldView()
                .fixedSize()
                .opacity(self.editing ? 1 : 0)
                .onBackgroundTap(enabled: editing, windowSize: containingWindowSize, viewFrame: frame) {
                    editing = false
                }
            
            labelView()
                .opacity(self.editing ? 0 : 1)
                .onTapGesture {
                    editing = true
                }
    
        }
        .readFrame($frame)
    }

    func labelView() -> some View {
        Text(text)
    }
    
    func textFieldView() -> some View {
        if !editing, text.isEmpty {
            text = "Empty"
        }
        return TextField("", text: $text,
            onEditingChanged: { status in

            },
            onCommit: {
                editing = false
                onEditEnd()
            }
        )
        .onExitCommand(perform: {
            editing = false
            onEditEnd()
        })
        .disabled(!editing)
    }
}
