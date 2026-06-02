//
//  BGTapsExamples.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 18.05.2026.
//

import SwiftUI
import PopupView

struct BGTapsExamplesView: View {

    private let values = [false, true]

    var body: some View {
        VStack {
            Button("Tap me") {
                print("I've been tapped")
            }
            .blueStyle()
            .padding(.bottom, 80)

            ButtonsMatrix(leftAxisTitle: "closeOnTapOutside", leftAxisValues: values, topAxisTitle: "allowTapThroughBG", topAxisValues: values) { closeOnTapOutside, allowTapThroughBG in
                VStack {
                    ForEach([Popup.DisplayMode.window, .sheet, .overlay]) { mode in
                        if mode == .overlay, allowTapThroughBG, closeOnTapOutside {
                            // .overlay can't allow taps through while also detecting them for popup dismiss
                            EmptyView()
                        }
                        else if mode == .sheet, allowTapThroughBG {
                            // .sheet can't allow taps through
                            EmptyView()
                        }
                        else {
                            BGTapsPopupShowingButton(mode: mode, closeOnTapOutside: closeOnTapOutside, allowTapThroughBG: allowTapThroughBG)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(30)
    }
}

struct BGTapsPopupShowingButton: View {
    var mode: Popup.DisplayMode
    var closeOnTapOutside: Bool
    var allowTapThroughBG: Bool

    @State private var show: Bool = false

    var body: some View {
        Button {
            show = true
        } label: {
            Text(String(describing: mode).capitalized)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(.white)
                        .shadow(radius: 2, x: 1, y: 2)
                }
        }
        .popup(isPresented: $show) {
            if mode != .overlay {
                BGTapsExamplePopup(mode: mode, closeOnTapOutside: closeOnTapOutside, allowTapThroughBG: allowTapThroughBG)
            } else {
                Rectangle()
                    .foregroundStyle(Color(.skyBlue))
                    .cornerRadius(3)
                    .frame(width: 20, height: 20)
            }
        } customize: {
            $0
                .displayMode(mode)
                .appearFrom(.centerScale)
                .closeOnTap(mode == .overlay)
                .closeOnTapOutside(closeOnTapOutside)
                .allowTapThroughBG(allowTapThroughBG)
        }
    }
}

struct BGTapsExamplePopup: View {
    @Environment(\.popupDismiss) var dismiss
    var mode: Popup.DisplayMode
    var closeOnTapOutside: Bool
    var allowTapThroughBG: Bool

    var body: some View {
        VStack(spacing: 12) {
            VStack {
                Text(String(describing: mode).capitalized)
                    .font(.system(size: 20))
                Text("closeOnTapOutside: \(String(describing: closeOnTapOutside))")
                Text("allowTapThroughBG: \(String(describing: allowTapThroughBG))")
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding()

            Button {
                dismiss?()
            } label: {
                Text("Thanks")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 24)
                    .foregroundColor(.white)
                    .background(Color(hex: "9265F8"))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .frame(width: UIScreen.main.bounds.width - 120)
        .shadowedStyle()
    }
}
