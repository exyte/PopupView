//
//  PopupModesView.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 18.05.2026.
//

import SwiftUI
import PopupView

struct PopupModesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ModeSectionView(mode: .window)
                ModeSectionView(mode: .overlay)
                ModeSectionView(mode: .sheet)
            }
        }
        .background(Color(.lightGrey).ignoresSafeArea())
    }
}

struct ModeSectionView: View {
    var mode: Popup.DisplayMode

    var body: some View {
        SectionHeader(name: String(describing: mode).capitalized)
        ForEach([true, false], id: \.self) { close in
            ForEach([true, false], id: \.self) { tap in
                if mode != .sheet || !tap { // .sheet can't allow taps through
                    PopupShowingButton(mode: mode, closeOnTapOutside: close, allowTapThroughBG: tap)
                }
            }
        }
    }
}

struct PopupShowingButton: View {
    var mode: Popup.DisplayMode
    var closeOnTapOutside: Bool
    var allowTapThroughBG: Bool

    @State private var show: Bool = false

    var body: some View {
        Button {
            show.toggle()
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)

                VStack(alignment: .leading, spacing: 0) {
                    Text("closeOnTapOutside: \(String(describing: closeOnTapOutside))")
                    Text("allowTapThroughBG: \(String(describing: allowTapThroughBG))")
                }
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding()
            }
        }
        .padding(.horizontal, 20)
        .popup(isPresented: $show) {
            ModeExamplePopup(mode: mode, closeOnTapOutside: closeOnTapOutside, allowTapThroughBG: allowTapThroughBG)
        } customize: {
            $0
                .displayMode(mode)
                .closeOnTap(false)
                .closeOnTapOutside(closeOnTapOutside)
                .allowTapThroughBG(allowTapThroughBG)
        }
    }
}

struct ModeExamplePopup: View {
    @Environment(\.popupDismiss) var dismiss
    var mode: Popup.DisplayMode
    var closeOnTapOutside: Bool
    var allowTapThroughBG: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image("winner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 226, maxHeight: 226)

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
        .shadowedStyle()
        .padding(.horizontal, 70)
    }
}
