//
//  ScrollExamplesView.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 29.05.2026.
//

import SwiftUI

struct ScrollExamplesView: View {

    private let values = [false, true]

    var body: some View {
        ButtonsMatrix(leftAxisTitle: "dragToDismiss", leftAxisValues: values, topAxisTitle: "needsScrollToFit", topAxisValues: values) { dragToDismiss, needsScrollToFit in
            ScrollPopupShowingButton(needsScrollToFit: needsScrollToFit, dragToDismiss: dragToDismiss)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 200)
    }
}

struct ScrollPopupShowingButton: View {
    var needsScrollToFit: Bool
    var dragToDismiss: Bool

    @State private var show: Bool = false

    var body: some View {
        Button {
            show.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .shadow(radius: 2, x: 1, y: 2)
        }
        .scrollPopup(isPresented: $show) {
            ScrollExamplePopup(needsScrollToFit: needsScrollToFit, dragToDismiss: dragToDismiss)
        } header: {
            scrollViewHeader()
        } customize: {
            $0
                .closeOnTap(false)
                .dragToDismiss(dragToDismiss)
                .closeOnTapOutside(!dragToDismiss)
                .backgroundColor(.black.opacity(0.4))
        }
    }

    func scrollViewHeader() -> some View {
        ZStack {
            Color(.white).cornerRadius(40, corners: [.topLeft, .topRight])

            Color.black
                .opacity(0.2)
                .frame(width: 30, height: 6)
                .clipShape(Capsule())
                .padding(.vertical, 20)
        }
    }
}

struct ScrollExamplePopup: View {
    @Environment(\.popupDismiss) var dismiss
    var needsScrollToFit: Bool
    var dragToDismiss: Bool

    var text: String {
        needsScrollToFit ? Constants.privacyPolicy : String(Constants.privacyPolicy.prefix(1000))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
                .font(.system(size: 24))

            VStack {
                Text("needsScrollToFit: \(String(describing: needsScrollToFit))")
                Text("dragToDismiss: \(String(describing: dragToDismiss))")
                if needsScrollToFit, !dragToDismiss {
                    Button("Dismiss") { dismiss?() }
                        .foregroundStyle(Color(.accent))
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()

            Text(text)
                .font(.system(size: 14))
                .opacity(0.6)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.white)
    }
}
