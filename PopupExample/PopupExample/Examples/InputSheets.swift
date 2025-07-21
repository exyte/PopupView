//
//  InputSheets.swift
//  PopupExample
//
//  Created by Alex.M on 28.09.2023.
//

import SwiftUI

struct InputSheetBottom: View {
    @Binding var isShowing: Bool

    @State var nickname: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Text("Nickname")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .bold))
                .kerning(0.38)

            Text("Usernames can only use letters, numbers, ., - and _ ")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 1, green: 0.23, blue: 0.19))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.98, green: 0.92, blue: 0.92))
                )
                .padding(.top, 16)

            TextField("Nickname", text: $nickname)
                .padding()
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1, green: 0.23, blue: 0.19), lineWidth: 0.5)
                )
                .padding(.top, 6)

            Button {
                isShowing = false
            } label: {
                Text("Save changes")
                    .buttonStyle(.plain)
                    .font(.system(size: 17))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.29, green: 0.38, blue: 1))
                    )
            }
            .buttonStyle(.plain)
            .foregroundColor(.white)
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color.white.cornerRadius(18))
        .shadowedStyle()
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
    }
}

#Preview {
    InputSheetBottom(isShowing: .constant(true))
}
