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
        Button {
            self.hideAll()
            self.showing.toggle()
        } label: {
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
    let cardColor = Color(hex: "3d5a80")

    @State var showingPopup = false
    @State var showingTopToast = false
    @State var showingBottomToast = false
    @State var showingTopFloater = false
    @State var showingBottomFloater = false
    @State var showingDraggableCard = false
    @State var showingScrollableDraggableCard = false

    var body: some View {

        let hideAll = {
            self.showingPopup = false
            self.showingTopToast = false
            self.showingBottomToast = false
            self.showingTopFloater = false
            self.showingBottomFloater = false
            self.showingDraggableCard = false
            self.showingScrollableDraggableCard = false
        }

        let commonView = ZStack {
            bgColor
            VStack(spacing: 15) {
                ExampleButton(showing: $showingPopup, title: "Popup", hideAll: hideAll)
                ExampleButton(showing: $showingTopToast, title: "Top toast", hideAll: hideAll)
                ExampleButton(showing: $showingBottomToast, title: "Bottom toast", hideAll: hideAll)
                ExampleButton(showing: $showingTopFloater, title: "Top floater", hideAll: hideAll)
                ExampleButton(showing: $showingBottomFloater, title: "Bottom floater", hideAll: hideAll)
                
#if os(iOS)
                ExampleButton(showing: $showingDraggableCard, title: "Draggable card", hideAll: hideAll)
                ExampleButton(showing: $showingScrollableDraggableCard, title: "Draggable scrollable card", hideAll: hideAll)
#endif
            }
        }
        .edgesIgnoringSafeArea(.all)

        .popup(isPresented: $showingPopup, type: .`default`, closeOnTap: false) {
            createPopup()
        }

        .popup(isPresented: $showingTopToast, type: .toast, position: .top) {
            createTopToast()
        }

        .popup(isPresented: $showingBottomToast, type: .toast, position: .bottom) {
            createBottomToast()
        }

        .popup(isPresented: $showingTopFloater, type: .floater(), position: .top, animation: .spring(), autohideIn: 2) {
            createTopFloater()
        }

        .popup(isPresented: $showingBottomFloater, type: .floater(), position: .bottom, animation: .spring(), autohideIn: 5) {
            createBottomFloater()
        }

#if os(iOS)
        return commonView
            .popup(isPresented: $showingDraggableCard, type: .toast, position: .bottom) {
                createDraggableCard()
            }
            .popup(isPresented: $showingScrollableDraggableCard, type: .toast, position: .bottom) {
                createScrollableDraggableCard()
            }
#else
        return commonView
#endif
    }

    func createPopup() -> some View {
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

            Button {
                self.showingPopup = false
            } label: {
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

    func createTopToast() -> some View {
        VStack {
            Spacer(minLength: 20)
            HStack {
                Image("shop_NA")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
            }
            .padding(15)
        }
        .frame(height: 110)
        .background(self.topToastColor)
    }

    func createBottomToast() -> some View {
        VStack {
            HStack {
                Image("grapes")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(self.bottomToastColor)
    }

    func createTopFloater() -> some View {
        HStack(spacing: 10) {
            Image("transaction_coffee")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(width: 20, height: 20)

            VStack(spacing: 8) {
                Text("Coffee temperature")
                    .font(.system(size: 12))
                    .foregroundColor(.white)

                HStack(spacing: 0) {
                    Color(red: 1, green: 112/255, blue: 59/255)
                        .frame(width: 30, height: 5)
                    Color(red: 1, green: 1, blue: 1)
                        .frame(width: 70, height: 5)
                }
                .cornerRadius(2.5)
            }
        }
        .frame(width: 200, height: 60)
        .background(self.topFloatColor)
        .cornerRadius(30.0)
    }

    func createBottomFloater() -> some View {
        HStack(spacing: 15) {
            Image("shop_coffee")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(width: 60, height: 60)
                .cornerRadius(10.0)

            VStack(alignment: .leading, spacing: 2) {
                Text("Ever thought of taking a break?")
                    .foregroundColor(.black)
                    .fontWeight(.bold)

                Text("Our hand picked organic fresh tasty coffee from southern slopes of Australia is bound to lighten your mood.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
        .padding(15)
        .frame(width: 300, height: 160)
        .background(self.bottomFloatColor)
        .cornerRadius(20.0)
    }

#if os(iOS)
    func createDraggableCard() -> some View {
        DraggableCardView(bgColor: cardColor) {
            VStack(spacing: 10) {
                Text("Weasels")
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text(Constants.shortText)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
        }
    }

    func createScrollableDraggableCard() -> some View {
        DraggableCardView(topPadding: 300, fixedHeight: true, bgColor: cardColor) {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Mongoose")
                        .foregroundColor(.white)
                        .fontWeight(.bold)

                    Text(Constants.longText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
            }
        }
    }
#endif
}

#if os(iOS)
struct DraggableCardView<Content: View>: View {

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
                Color.white
                    .frame(width: 72, height: 6)
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
#endif
