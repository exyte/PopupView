//
//  FloatsBig.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 09.06.2023.
//

import SwiftUI

struct FloatTopLeading: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("dark"))

            HStack(alignment: .top, spacing: 16) {
                Picture("avatar6", 48)

                VStack(alignment: .leading, spacing: 2) {
                    WhiteBoldText("You are on Do Not Distrub")
                    WhiteText("Do you want to update your status?", 13)
                        .opacity(0.6)

                    HStack(spacing: 18) {
                        WhiteBoldText("Turn on")
                            .padding(16, 5)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color("darkBlue")))
                        WhiteText("Stay off", 16)
                            .opacity(0.6)
                    }
                    .padding(.top, 14)
                }

                Spacer()

                Picture("cross", 10)
            }
            .padding(16)
        }
        .fixedSize()
    }
}

struct FloatTop: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("semidark"))

            HStack(spacing: 16) {
                Picture("avatar5", 48)

                VStack(alignment: .leading, spacing: 2) {
                    WhiteMediumText("Kate Middleton", 17)
                    WhiteText("incoming call", 13)
                        .opacity(0.6)
                }
                .padding(.trailing, 60)

                HStack(spacing: 14) {
                    Picture("phone_call", 36)
                    Picture("phone_call2", 36)
                }
            }
            .padding(14)
        }
        .fixedSize()
    }
}

struct FloatTopTrailing: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("light"))

            HStack(spacing: 7) {
                Circle()
                    .foregroundColor(Color("darkBlue"))
                    .frame(width: 10, height: 10)

                Picture("avatar4", 45)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        BlackBoldText("@edsheeran", 16)
                        BlackText ("followed you", 16)
                            .opacity(0.4)
                            .padding(.trailing, 15)
                        DarkText("8:02 am", 13)
                            .opacity(0.6)
                    }
                    .padding(.trailing, 8)
                    .fixedSize()
                    DarkText("I know it's a bad idea. But how can I help\nmyself?", 13)
                        .opacity(0.6)
                }
            }
            .padding(8)
        }
        .fixedSize()
    }
}

struct FloatLeading: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("purple"))
                .overlay(
                    Picture("cross", 10)
                        .padding(13)
                    , alignment: .topTrailing
                )

            VStack(alignment: .leading, spacing: 8) {
                Picture("gift2", 33)
                    .padding(.bottom, 20)

                WhiteBoldText("We give you a gift!")
                WhiteText("30% discount until the end of the month on all products of the company.", 13)
                    .opacity(0.8)
            }
            .padding(16)
        }
        .frame(width: 195)
        .fixedSize()
    }
}

struct FloatTrailing: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("semilight"))

            HStack {
                Picture("check_circle", 27)
                BlackText("New file created with success", 15)
            }
            .padding(20, 15)
        }
        .fixedSize()
    }
}

struct FloatBottomLeading: View {

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
                .frame(width: 21, height: 21)
            WhiteText("Check your network connection and try again", 15)
        }
        .padding(32, 22)
        .background(Color("yellow").cornerRadius(12))
    }
}

struct FloatBottom: View {

    var body: some View {
        ZStack {
            Capsule()
                .fill(.black)

            HStack(spacing: 25) {
                Picture("file", 20)
                VStack(spacing: 2) {
                    WhiteBoldText("Ooops! Download failed")
                    WhiteText("The download was unable to complete. Please try again later.", 16)
                        .opacity(0.6)
                }
                Text("Retry")
                    .font(.custom(boldFont, size: 21))
                    .foregroundColor(Color("lightBlue"))
            }
            .padding(26, 20)
        }
        .fixedSize()
    }
}

struct FloatBottomTrailing: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)

            HStack(spacing: 0) {
                BlackText("Your message has been sent to Alex Brant", 15)
                    .padding(20)
                Picture("avatar2", 32)
                    .padding(.trailing, 7)
            }
        }
        .shadowedStyle()
        .fixedSize()
    }
}

struct Picture: View {
    let name: String
    let size: CGFloat

    init(_ name: String, _ size: CGFloat) {
        self.name = name
        self.size = size
    }

    var body: some View {
        Image(name)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: size)
    }
}

let boldFont = "NunitoSans7pt-Bold"
let mediumFont = "NunitoSans7pt-Medium"
let lightFont = "NunitoSans7pt-Light"
let regularFont = "NunitoSans7pt-Regular"

struct WhiteBoldText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat = 16) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(boldFont, size: size))
            .foregroundColor(.white)
            .bold()
    }
}

struct WhiteMediumText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(mediumFont, size: size))
            .foregroundColor(.white)
    }
}

struct WhiteText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(regularFont, size: size))
            .foregroundColor(.white)
    }
}

struct BlackBoldText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(boldFont, size: size))
            .foregroundColor(.black)
            .bold()
    }
}

struct BlackMediumText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(mediumFont, size: size))
            .foregroundColor(.white)
    }
}

struct BlackText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(regularFont, size: size))
            .foregroundColor(.black)
    }
}

struct DarkText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, _ size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(regularFont, size: size))
            .foregroundColor(Color("darkText"))
    }
}

extension View {
    func padding(_ horizontal: CGFloat, _ vertical: CGFloat) -> some View {
        self.padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }
}
