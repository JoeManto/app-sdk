//
//  DetailsView.swift
//
//
//  Created by Joe Manto on 7/13/24.
//

import SwiftUI

#if os(macOS)
@available(macOS 14.0, *)
public struct DetailsView<Content: View, Details: View, Label: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var details: Details
    @ViewBuilder var label: Label

    @Binding var showingDetails: Bool

    @State private var contentVisibility = true
    @State private var detailsStatus: Bool

    public init(
        showingDetails: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content,
        @ViewBuilder details: () -> Details
    ) {
        self.detailsStatus = showingDetails.wrappedValue
        self._showingDetails = showingDetails
        self.label = label()
        self.content = content()
        self.details = details()
    }

    public var body: some View {
        VStack {
            HStack {
                if detailsStatus {
                    Button("Back", systemImage: "chevron.left", action: {
                        withAnimation {
                            contentVisibility = true
                            showingDetails = false
                        }
                    })
                    .accessibilityHint("Go back")
                    .buttonStyle(BorderlessButtonStyle())
                }

                Spacer()
                
                if !detailsStatus {
                    Button(action: {
                        contentVisibility = false
                        withAnimation {
                            contentVisibility = true
                            showingDetails = true
                        }
                    }, label: {
                        label
                    })
                    .accessibilityHint("Show details")
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding()

            if detailsStatus {
                details
                    .transition(AnyTransition.backslide(offset: CGSize(width: 300, height: 0)))
            } else {
                content
                    .opacity(contentVisibility ? 1.0 : 0.0)
                    .transition(AnyTransition.backslide(offset: CGSize(width: 300, height: 0)))
            }

            Spacer()
        }
        .onChange(of: showingDetails) { _, new in
            guard detailsStatus != new else {
                return
            }

            withAnimation {
                detailsStatus = new
            }
        }
        .onChange(of: detailsStatus) { _, new in
            guard showingDetails != new else {
                return
            }

            showingDetails = new
        }
    }
}
#endif
