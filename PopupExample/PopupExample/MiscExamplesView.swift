//
//  MiscExamplesView.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 22.05.2026.
//

import SwiftUI
import PopupView

struct MiscExamplesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Issue #281 reproduction: .scroll type + useKeyboardSafeArea(true) + TextField
                // Bug: entire popup shifts up by full keyboard height instead of shrinking scroll area
                MiscPopupShowingButton(
                    title: "Scroll + Keyboard (issue #281)",
                    details: "Scroll popup with TextField - popup should stay at bottom"
                ) {
                    ScrollInputSheet()
                } customizeScroll: {
                    $0
                        .closeOnTap(false)
                        .closeOnTapOutside(true)
                        .backgroundColor(.black.opacity(0.4))
                        .useKeyboardSafeArea(true)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.lightGrey).ignoresSafeArea())
    }
}

struct MiscPopupShowingButton<PopupContent: View>: View {
    var title: String
    var details: String

    @ViewBuilder var popupContent: () -> PopupContent
    var customize: ((Popup.PopupTypeParameters) -> Popup.PopupTypeParameters)?
    var customizeScroll: ((Popup.ScrollPopupParameters) -> Popup.ScrollPopupParameters)?

    @State private var show = false

    var body: some View {
        Button {
            show = true
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 18))

                    Text(details)
                        .font(.system(size: 13))
                        .opacity(0.4)
                }
                .foregroundStyle(.black)
                .padding()
            }
        }
        .applyIfNotNil(customize) { view, customize in
            view
                .popup(isPresented: $show) {
                    popupContent()
                } customize: {
                    customize($0)
                }
        }
        .applyIfNotNil(customizeScroll) { view, customize in
            view
                .scrollPopup(isPresented: $show) {
                    popupContent()
                } customize: {
                    customize($0)
                }
        }

    }
}

// Reproduces issue #281: .scroll type popup with useKeyboardSafeArea(true) shifts
// the entire popup off-screen when the keyboard appears, instead of constraining
// only the ScrollView height.
struct ScrollInputSheet: View {

    @State var comment: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Scrollable content area
            ForEach(0..<8, id: \.self) { i in
                Text("Item \(i + 1)")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                Divider().padding(.horizontal, 20)
            }

            // TextField at the bottom of the scroll content
            TextField("Leave a comment...", text: $comment)
                .padding()
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}
