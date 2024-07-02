//
//  ContentView.swift
//  Example
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import PopupView

class SomeItem: Equatable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    static func == (lhs: SomeItem, rhs: SomeItem) -> Bool {
        lhs.value == rhs.value
    }
}

struct FloatsStateBig {
    var showingTopLeading = false
    var showingTop = false
    var showingTopTrailing = false

    var showingLeading = false
    // center is a regular popup
    var showingTrailing = false

    var showingBottomLeading = false
    var showingBottom = false
    var showingBottomTrailing = false
}

struct FloatsStateSmall {
    var showingTopFirst = false
    var showingTopSecond = false
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct ToastsState {
    var showingTopFirst = false
    var showingTopSecond = false
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct PopupsState {
    var middleItem: SomeItem?
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct ActionSheetsState {
    var showingFirst = false
    var showingSecond = false
}

struct InputSheetsState {
    var showingFirst = false
}

struct ContentView : View {
    @State var floatsSmall = FloatsStateSmall()
    @State var floatsBig = FloatsStateBig()
    @State var toasts = ToastsState()
    @State var popups = PopupsState()
    @State var actionSheets = ActionSheetsState()
    @State var inputSheets = InputSheetsState()

    var body: some View {
        createPopupsList()

        // MARK: - Designed floats big screen

            .popup(isPresented: $floatsBig.showingTopLeading) {
                FloatTopLeading()
            } customize: {
                $0
                    .type(.floater())
                    .position(.topLeading)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingTop) {
                FloatTop()
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingTopTrailing) {
                FloatTopTrailing()
            } customize: {
                $0
                    .type(.floater())
                    .position(.topTrailing)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingLeading) {
                FloatLeading()
            } customize: {
                $0
                    .type(.floater())
                    .position(.leading)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingTrailing) {
                FloatTrailing()
            } customize: {
                $0
                    .type(.floater())
                    .position(.trailing)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingBottomLeading) {
                FloatBottomLeading()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottomLeading)
                    .appearFrom(.bottomSlide)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingBottom) {
                FloatBottom()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsBig.showingBottomTrailing) {
                FloatBottomTrailing()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottomTrailing)
                    .animation(.spring())
            }

        // MARK: - Designed floats small screen

            .popup(isPresented: $floatsSmall.showingTopFirst) {
                FloatTopFirst(isShowing: $floatsSmall.showingTopFirst)
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .autohideIn(3)
                    .dismissCallback {
                        print("did", $0)
                    }
                    .willDismissCallback {
                        print("will", $0)
                    }
            }

            .popup(isPresented: $floatsSmall.showingTopSecond) {
                FloatTopSecond()
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .autohideIn(3)
            }

            .popup(isPresented: $floatsSmall.showingBottomFirst) {
                FloatBottomFirst()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
            }

            .popup(isPresented: $floatsSmall.showingBottomSecond) {
                FloatBottomSecond()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
            }

        // MARK: - Designed toasts

            .popup(isPresented: $toasts.showingTopFirst) {
                ToastTopFirst()
            } customize: {
                $0
                    .type(.toast)
                    .position(.top)
            }

            .popup(isPresented: $toasts.showingTopSecond) {
                ToastTopSecond()
            } customize: {
                $0
                    .type(.toast)
                    .position(.top)
            }

            .popup(isPresented: $toasts.showingBottomFirst) {
                ToastBottomFirst(isShowing: $toasts.showingBottomFirst)
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }

            .popup(isPresented: $toasts.showingBottomSecond) {
                ToastBottomSecond()
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .autohideIn(10)
            }

        // MARK: - Designed popups

            .popup(item: $popups.middleItem) { item in
                PopupMiddle(item: item) {
                    popups.middleItem = nil
                }
            } customize: {
                $0
                    .appearFrom(.centerScale)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }

            .popup(isPresented: $popups.showingBottomFirst) {
                PopupBottomFirst(isPresented: $popups.showingBottomFirst)
            } customize: {
                $0
                    .type(.floater())
                    .disappearTo(.centerScale)
                    .position(.bottom)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }

            .popup(isPresented: $popups.showingBottomSecond) {
                PopupBottomSecond()
            } customize: {
                $0
                    .type(.floater(verticalPadding: 0, useSafeAreaInset: false))
                    .position(.bottom)
                    .closeOnTap(true)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }

#if os(iOS)
        // MARK: - Designed action sheets
            .popup(isPresented: $actionSheets.showingFirst) {
                ActionSheetFirst()
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }
            .popup(isPresented: $actionSheets.showingSecond) {
                ActionSheetSecond()
            } customize: {
                $0
                    .type(.scroll(headerView: AnyView(scrollViewHeader())))
                    .position(.bottom)
                    .closeOnTap(false)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }

#endif

            .popup(isPresented: $inputSheets.showingFirst) {
                InputSheetBottom(isShowing: $inputSheets.showingFirst)
            } customize: {
                $0
                    .position(.bottom)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
                    .isOpaque(true)
                    .useKeyboardSafeArea(true)
            }
    }

    func createPopupsList() -> PopupsList {
        PopupsList(
            floatsBig: $floatsBig,
            floatsSmall: $floatsSmall,
            toasts: $toasts,
            popups: $popups,
            actionSheets: $actionSheets,
            inputSheets: $inputSheets,
            hideAll: {
                floatsBig = FloatsStateBig()
                floatsSmall = FloatsStateSmall()
                toasts = ToastsState()
                popups = PopupsState()
                actionSheets = ActionSheetsState()
                inputSheets = InputSheetsState()
            }
        )
    }

#if os(iOS)
    func scrollViewHeader() -> some View {
        ZStack {
            Color(.white).cornerRadius(40, corners: [.topLeft, .topRight])

            Color.black
                .opacity(0.2)
                .frame(width: 30, height: 6)
                .clipShape(Capsule())
                .padding(.vertical, 20)
        }
    }
#endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
