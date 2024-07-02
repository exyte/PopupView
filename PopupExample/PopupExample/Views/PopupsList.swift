//
//  PopupsList.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

private struct SectionHeader: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(0.8)
                
                Text("types")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct PopupTypeView<Content> : View where Content : View {
    let title: String
    var detail: String = ""
    @ViewBuilder let icon: () -> Content
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
            
            HStack {
                icon()
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                        .opacity(0.4)
                }
            }
            .padding()
        }
        .padding(.horizontal, 20)
    }
}

struct PopupsList: View {
    @Binding var floatsBig: FloatsStateBig
    @Binding var floatsSmall: FloatsStateSmall
    @Binding var toasts: ToastsState
    @Binding var popups: PopupsState
    @Binding var actionSheets: ActionSheetsState
    @Binding var inputSheets: InputSheetsState

    let hideAll: () -> ()

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "F7F7F9"))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    safeSpaceForMac()

                    Group {
                        SectionHeader(name: "Floats", count: 4)
                            .padding(.bottom, 12)
                        
                        floatsSection()
                    }

                    Group {
                        SectionHeader(name: "Toasts", count: 4)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                        
                        toastsSection()
                    }

                    Group {
                        SectionHeader(name: "Popups", count: 3)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))

                        popupsSection()
                    }
                    
#if os(iOS)
                    Group {
                        SectionHeader(name: "Action sheets", count: 2)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                        
                        actionSheetsSection()
                    }
#endif

                    Group {
                        SectionHeader(name: "Inputs", count: 1)
                            .padding(.bottom, 12)

                        inputsSection()
                    }

                    safeSpaceForMac()
                }
            }
            .padding(.top, 1)
        }
    }

    func safeSpaceForMac() -> some View {
#if os(macOS)
        Color.clear.padding(.bottom, 40)
#else
        EmptyView()
#endif
    }

    @MainActor @ViewBuilder
    func floatsSection() -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            floatsSectionSmall()
        } else {
            floatsSectionBig()
        }
#else
        floatsSectionBig()
#endif
    }

    @ViewBuilder
    func floatsSectionSmall() -> some View {
        PopupButton(isShowing: $floatsSmall.showingTopFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Top version 1",
                detail: "Top float with a picture and one button"
            ) {
                SmallFloatsImage(alignment: .top)
            }
        }
        PopupButton(isShowing: $floatsSmall.showingTopSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Top version 2",
                detail: "Top float with a picture"
            ) {
                SmallFloatsImage(alignment: .top)
            }
        }
        PopupButton(isShowing: $floatsSmall.showingBottomFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 1",
                detail: "Bottom float with a picture"
            ) {
                SmallFloatsImage(alignment: .bottom)
            }
        }
        PopupButton(isShowing: $floatsSmall.showingBottomSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 2",
                detail: "Bottom float with a picture"
            ) {
                SmallFloatsImage(alignment: .bottom)
            }
        }
    }

    @ViewBuilder
    func floatsSectionBig() -> some View {
        PopupButton(isShowing: $floatsBig.showingTopLeading, hideAll: hideAll) {
            PopupTypeView(title: "Top Leading") {
                BigFloatsImage(alignment: .topLeading)
            }
        }
        PopupButton(isShowing: $floatsBig.showingTop, hideAll: hideAll) {
            PopupTypeView(title: "Top Center") {
                BigFloatsImage(alignment: .top)
            }
        }
        PopupButton(isShowing: $floatsBig.showingTopTrailing, hideAll: hideAll) {
            PopupTypeView(title: "Top Trailing") {
                BigFloatsImage(alignment: .topTrailing)
            }
        }

        PopupButton(isShowing: $floatsBig.showingLeading, hideAll: hideAll) {
            PopupTypeView(title: "Center Leading") {
                BigFloatsImage(alignment: .leading)
            }
        }
        PopupButton(isShowing: $floatsBig.showingTrailing, hideAll: hideAll) {
            PopupTypeView(title: "Center Trailing") {
                BigFloatsImage(alignment: .trailing)
            }
        }

        PopupButton(isShowing: $floatsBig.showingBottomLeading, hideAll: hideAll) {
            PopupTypeView(title: "Bottom Leading") {
                BigFloatsImage(alignment: .bottomLeading)
            }
        }
        PopupButton(isShowing: $floatsBig.showingBottom, hideAll: hideAll) {
            PopupTypeView(title: "Bottom Center") {
                BigFloatsImage(alignment: .bottom)
            }
        }
        PopupButton(isShowing: $floatsBig.showingBottomTrailing, hideAll: hideAll) {
            PopupTypeView(title: "Bottom Trailing") {
                BigFloatsImage(alignment: .bottomTrailing)
            }
        }
    }

    @ViewBuilder
    func toastsSection() -> some View {
        PopupButton(isShowing: $toasts.showingTopFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Top version 1",
                detail: "Top toast only text"
            ) {
                ToastImage(position: .top)
            }
        }
        PopupButton(isShowing: $toasts.showingTopSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Top version 2",
                detail: "Top float with picture"
            ) {
                ToastImage(position: .top)
            }
        }
        PopupButton(isShowing: $toasts.showingBottomFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 1",
                detail: "Bottom float with a picture and two buttons"
            ) {
                ToastImage(position: .bottom)
            }
        }
        PopupButton(isShowing: $toasts.showingBottomSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 2",
                detail: "Bottom float with a picture"
            ) {
                ToastImage(position: .bottom)
            }
        }
    }

    @ViewBuilder
    func popupsSection() -> some View {
        ItemPopupButton(item: $popups.middleItem, hideAll: hideAll) {
            PopupTypeView(
                title: "Middle",
                detail: "Popup in the middle of the screen with a picture"
            ) {
                PopupImage(style: .default)
            }
        }
        PopupButton(isShowing: $popups.showingBottomFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 1",
                detail: "Popup bottom"
            ) {
                PopupImage(style: .bottomFirst)
            }
        }
        PopupButton(isShowing: $popups.showingBottomSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom version 2",
                detail: "Popup bottom"
            ) {
                PopupImage(style: .bottomSecond)
            }
        }
    }

    @ViewBuilder
    func actionSheetsSection() -> some View {
        PopupButton(isShowing: $actionSheets.showingFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Version 1",
                detail: "Action sheets"
            ) {
                ActionSheetImage()
            }
        }
        PopupButton(isShowing: $actionSheets.showingSecond, hideAll: hideAll) {
            PopupTypeView(
                title: "Version 2",
                detail: "Action sheets"
            ) {
                ActionSheetImage()
            }
        }
    }

    @ViewBuilder
    func inputsSection() -> some View {
        PopupButton(isShowing: $inputSheets.showingFirst, hideAll: hideAll) {
            PopupTypeView(
                title: "Bottom Input",
                detail: "Popup in the bottom of the screen with an input text field"
            ) {
                InputSheetImage()
            }
        }
    }
}

struct PopupsList_Previews: PreviewProvider {
    static var previews: some View {
        PopupButton(
            isShowing: Binding<Bool>.init(get: { true },
                                        set: { _ in }),
            hideAll: {})
        {
            PopupTypeView(
                title: "Top version 1",
                detail: "Top float with a picture and one button"
            ) {
                BigFloatsImage(alignment: .top)
            }
        }
    }
}
