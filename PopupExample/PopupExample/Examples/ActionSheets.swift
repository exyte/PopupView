//
//  ActionSheets.swift
//  Example
//
//  Created by Alex.M on 20.05.2022.
//

import SwiftUI

#if os(iOS)
struct ActionSheetView<Content: View>: View {

    let content: Content
    let topPadding: CGFloat
    let fixedHeight: Bool
    let bgColor: Color

    init(topPadding: CGFloat = 100, fixedHeight: Bool = false, bgColor: Color = .white, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.topPadding = topPadding
        self.fixedHeight = fixedHeight
        self.bgColor = bgColor
    }

    var body: some View {
        ZStack {
            bgColor.cornerRadius(40, corners: [.topLeft, .topRight])
            VStack {
                Color.black
                    .opacity(0.2)
                    .frame(width: 30, height: 6)
                    .clipShape(Capsule())
                    .padding(.top, 15)
                    .padding(.bottom, 10)

                content
                    .padding(.bottom, 30)
                    .applyIf(fixedHeight) {
                        $0.frame(height: UIScreen.main.bounds.height - topPadding)
                    }
                    .applyIf(!fixedHeight) {
                        $0.frame(maxHeight: UIScreen.main.bounds.height - topPadding)
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ActivityView: View {
    let emoji: String
    let name: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))

            Text(name.uppercased())
                .font(.system(size: 13, weight: isSelected ? .regular : .light))

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(Color(hex: "9265F8"))
            }
        }
        .opacity(isSelected ? 1.0 : 0.8)
    }
}

struct ActionSheetFirst: View {
    var body: some View {
        ActionSheetView(bgColor: .white) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ActivityView(emoji: "🤼‍♂️", name: "Sparring", isSelected: true)
                    ActivityView(emoji: "🧘", name: "Yoga", isSelected: false)
                    ActivityView(emoji: "🚴", name: "cycling", isSelected: false)
                    ActivityView(emoji: "🏊", name: "Swimming", isSelected: false)
                    ActivityView(emoji: "🏄", name: "Surfing", isSelected: false)
                    ActivityView(emoji: "🤸", name: "Fitness", isSelected: false)
                    ActivityView(emoji: "⛹️", name: "Basketball", isSelected: true)
                    ActivityView(emoji: "🏋️", name: "Lifting Weights", isSelected: false)
                    ActivityView(emoji: "⚽️", name: "Football", isSelected: false)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ActionSheetSecond: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
                .font(.system(size: 24))

            Text(Constants.privacyPolicy)
                .font(.system(size: 14))
                .opacity(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

struct ActionSheets_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            ActionSheetFirst()
        }

        ZStack {
            Rectangle()
                .ignoresSafeArea()
            ActionSheetSecond()
        }
    }
}

#endif
