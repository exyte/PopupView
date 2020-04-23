//
//  ContentView.swift
//  Example
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import PopupView

struct ExampleButton : View {

    @Binding var showing: Bool
    var title: String
    var hideAll: ()->()

    var body: some View {
        Button(action: {
            self.hideAll()
            self.showing.toggle()
        }) {
            Text(title)
                .foregroundColor(.black)
        }
    }
}

struct ContentView : View {

    let bgColor = Color(hex: "e0fbfc")
    let popupColor = Color(hex: "3d5a80")
    let topToastColor = Color(hex: "293241")
    let bottomToastColor = Color(hex: "98c1d9")
    let topFloatColor = Color(hex: "293241")
    let bottomFloatColor = Color(hex: "ee6c4d")

    @State var showingPopup = false
    @State var showingTopToast = false
    @State var showingBottomToast = false
    @State var showingTopFloater = false
    @State var showingBottomFloater = false

    var body: some View {

        let hideAll = {
            self.showingPopup = false
            self.showingTopToast = false
            self.showingBottomToast = false
            self.showingTopFloater = false
            self.showingBottomFloater = false
        }

        return ZStack {
            bgColor
            VStack(spacing: 15) {
                ExampleButton(showing: $showingPopup, title: "Popup", hideAll: hideAll)
                ExampleButton(showing: $showingTopToast, title: "Top toast", hideAll: hideAll)
                ExampleButton(showing: $showingBottomToast, title: "Bottom toast", hideAll: hideAll)
                ExampleButton(showing: $showingTopFloater, title: "Top floater", hideAll: hideAll)
                ExampleButton(showing: $showingBottomFloater, title: "Bottom floater", hideAll: hideAll)
            }
        }
        .edgesIgnoringSafeArea(.all)
            
        .popup(presented: $showingPopup, type: .popup, onTap: {}) {
            VStack(spacing: 10) {
                Image("okay")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 100, height: 100)

                Text("Tutorial")
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text("In this example floats are set to disappear after 2 seconds. Tap the toasts to dismiss or just open some other popup - previous one will be dismissed. This popup will only be closed if you tap the button.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))

                Spacer()

                Button(action: {
                    self.showingPopup = false
                }) {
                    Text("Got it")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                }
                .frame(width: 100, height: 40)
                .background(Color.white)
                .cornerRadius(20.0)
            }
            .padding(EdgeInsets(top: 70, leading: 20, bottom: 40, trailing: 20))
            .frame(width: 300, height: 400)
            .background(self.popupColor)
            .cornerRadius(10.0)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        }

        .popup(presented: $showingTopToast, type: .topToast) {
            VStack {
                Spacer(minLength: 20)
                HStack() {
                    Image("shop_NA")
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Nik")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Spacer()
                            Text("11:30")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                        }

                        Text("How about a dinner in an hour? We could discuss that one urgent issue we should be discussing.")
                            .lineLimit(2)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }.padding(15)
            }
            .frame(width: UIScreen.main.bounds.width, height: 110)
            .background(self.topToastColor)
        }

        .popup(presented: $showingBottomToast, type: .bottomToast) {
            VStack {
                HStack() {
                    Image("grapes")
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grapes! Grapes! Grapes!")
                            .foregroundColor(.black)
                            .fontWeight(.bold)

                        Text("Step right up! Buy some grapes now - that's a brilliant investment and you know it!")
                            .lineLimit(2)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                Spacer(minLength: 10)
            }
            .padding(15)
            .frame(width: UIScreen.main.bounds.width, height: 100)
            .background(self.bottomToastColor)
        }

        .popup(presented: $showingTopFloater, type: .topFloater(), animation: Animation.spring(), autohideIn: 2) {
            HStack(spacing: 10) {
                Image("transaction_coffee")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 20, height: 20)
                VStack(spacing: 8) {
                    Text("Coffee temprature")
                        .font(.system(size: 12))
                        .foregroundColor(.white)

                    HStack(spacing: 0) {
                        Color(red: 1, green: 112/255, blue: 59/255)
                            .frame(width: 30, height: 5)
                        Color(red: 1, green: 1, blue: 1)
                            .frame(width: 70, height: 5)
                    }.cornerRadius(2.5)
                }
            }
            .frame(width: 200, height: 60)
            .background(self.topFloatColor)
            .cornerRadius(30.0)
        }

        .popup(presented: $showingBottomFloater, type: .bottomFloater(), animation: Animation.spring(), autohideIn: 5) {
            HStack(spacing: 15) {
                Image("shop_coffee")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10.0)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ever though of taking a break?")
                        .foregroundColor(.black)
                        .fontWeight(.bold)

                    Text("Our hand picked organic fresh tasty coffee from southern slopes of Australia is bound to lighten you mood.")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            .padding(15)
            .frame(width: 300, height: 160)
            .background(self.bottomFloatColor)
            .cornerRadius(20.0)
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
