//
//  ContentView.swift
//  Example
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import ExytePopupView

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
        }.frame(maxHeight: 20)
    }
}

struct ContentView : View {

    let bgColor = Color(hex: "e0fbfc")
    let popupColor = Color(hex: "3d5a80")
    let topToastColor = Color(hex: "293241")
    let bottomToastColor = Color(hex: "98c1d9")
    let topFloatColor = Color(hex: "293241")
    let bottomFloatColor = Color(hex: "ee6c4d")

    @State var showingTopToast = false
    @State var showingBottomToast = false
    @State var showingTopFloater = false

    private var screenSize: CGSize {
        WKInterfaceDevice.current().screenBounds.size
    }

    var body: some View {

        let hideAll = {
            self.showingTopToast = false
            self.showingBottomToast = false
            self.showingTopFloater = false
        }

        return ZStack {
            bgColor
            VStack(spacing: 8) {
                ExampleButton(showing: $showingTopToast, title: "Top toast", hideAll: hideAll)
                ExampleButton(showing: $showingBottomToast, title: "Bottom toast", hideAll: hideAll)
                ExampleButton(showing: $showingTopFloater, title: "Top floater", hideAll: hideAll)
            }
        }
        .edgesIgnoringSafeArea(.all)

        .popup(isPresented: $showingTopToast, type: .toast, position: .top) {
            createTopToast()
        }

        .popup(isPresented: $showingBottomToast, type: .toast, position: .bottom) {
            createBottomToast()
        }

        .popup(isPresented: $showingTopFloater, type: .floater(), position: .top, animation: Animation.spring(), autohideIn: 2) {
            createTopFloater()
        }

    }

    func createTopToast() -> some View {
        GeometryReader { proxy -> AnyView in
            AnyView(VStack {
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
            .frame(width: proxy.size.width, height: 110)
            .background(self.topToastColor))
        }
    }

    func createBottomToast() -> some View {
        VStack {
            HStack() {
                Image("grapes")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Grapes!")
                        .foregroundColor(.black)
                        .fontWeight(.bold)

                    Text("Step right up!")
                        .lineLimit(2)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            Spacer(minLength: 10)
        }
        .padding(15)
        .frame(width: screenSize.width, height: 60)
        .background(self.bottomToastColor)
    }

    func createTopFloater() -> some View {
        HStack(spacing: 10) {
            Image("transaction_coffee")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(width: 20, height: 20)
            VStack(spacing: 8) {
                Text("Temperature")
                    .font(.system(size: 12))
                    .foregroundColor(.white)

                HStack(spacing: 0) {
                    Color(red: 1, green: 112/255, blue: 59/255)
                        .frame(width: 20, height: 5)
                    Color(red: 1, green: 1, blue: 1)
                        .frame(width: 60, height: 5)
                }.cornerRadius(2.5)
            }
        }
        .frame(width: 150, height: 60)
        .background(self.topFloatColor)
        .cornerRadius(30.0)
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
