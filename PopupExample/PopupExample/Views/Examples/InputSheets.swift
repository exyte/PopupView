//
//  InputSheets.swift
//  PopupExample
//
//  Created by Alex.M on 28.09.2023.
//

import SwiftUI

struct InputSheetMiddle: View {
    @Binding var isShowing: Bool

    @State var firstName: String = ""
    @State var secondName: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("Fill fields")
                .foregroundColor(.black)
                .font(.system(size: 24))
                .padding(.top, 12)

            Text("We need to know")
                .foregroundColor(.black)
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)

            TextField("First name", text: $firstName)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.black)
                }

            TextField("Second name", text: $secondName)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.black)
                }

            Button("Done") {
                isShowing = false
            }
            .buttonStyle(.plain)
            .font(.system(size: 18, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
            .background(Color(hex: "9265F8"))
            .cornerRadius(12)
            .padding(.top, 30)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .shadowedStyle()
        .padding(.horizontal, 40)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isShowing = false
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    InputSheetMiddle(isShowing: .constant(true))
}
