//
//  ContentView.swift
//  Example
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import ExytePopupView

struct ToastsState {
    var showingTopFirst = false
    var showingTopSecond = false
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct PopupsState {
    var showingMiddle = false
    var showingBottomFirst = false
    var showingBottomSecond = false
    var popupItem: String?
}

struct ActionSheetsState {
    var showingFirst = false
    var showingSecond = false
    var text: String?
}

struct ContentView : View {
    @State var floats = ToastsState()
    @State var toasts = ToastsState()
    @State var popups = PopupsState()
    @State var actionSheets = ActionSheetsState()
    @State private var item: String?
    var body: some View {
        let commonView = createPopupsList()
        
        // MARK: - Designed floats

            .popup(isPresented: $floats.showingTopFirst) {
                FloatTopFirst(isShowing: $floats.showingTopFirst)
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .dismissSourceCallback {
                        print($0)
                    }
            }

            .popup(isPresented: $floats.showingTopSecond) {
                FloatTopSecond()
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .autohideIn(3)
            }

            .popup(isPresented: $floats.showingBottomFirst) {
                FloatBottomFirst()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .autohideIn(2)
            }

            .popup(isPresented: $floats.showingBottomSecond) {
                FloatBottomSecond()
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .autohideIn(5)
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

//        // MARK: - Designed popups

            .popup(isPresented: $popups.showingMiddle) {
                PopupMiddle(isPresented: $popups.showingMiddle,
                            item: "In two weeks, you did 12 workouts and burned 2671 calories. That's 566 calories more than last month. Continue at the same pace and the result will please you.")
            } customize: {
                $0
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }
            .itemPopup(item: $popups.popupItem, customize: {
                $0
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }, itemView: { item in
                PopupMiddle(isPresented: $popups.showingMiddle, item: item) {
                    popups.popupItem = nil
                }
            })
            .popup(isPresented: $popups.showingBottomFirst) {
                PopupBottomFirst(isPresented: $popups.showingBottomFirst)
            } customize: {
                $0
                    .type(.floater())
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
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }

#if os(iOS)
        // MARK: - Designed action sheets
        return commonView
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
                    .type(.toast)
                    .position(.bottom)
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }
#else
        return commonView
#endif
    }
    
    func createPopupsList() -> PopupsList {
#if os(iOS)
        PopupsList(
            showingTopFirstFloat: $floats.showingTopFirst,
            showingTopSecondFloat: $floats.showingTopSecond,
            showingBottomFirstFloat: $floats.showingBottomFirst,
            showingBottomSecondFloat: $floats.showingBottomSecond,
            showingTopFirstToast: $toasts.showingTopFirst,
            showingTopSecondToast: $toasts.showingTopSecond,
            showingBottomFirstToast: $toasts.showingBottomFirst,
            showingBottomSecondToast: $toasts.showingBottomSecond,
            showingMiddlePopup: $popups.showingMiddle,
            showingBottomFirstPopup: $popups.showingBottomFirst,
            showingBottomSecondPopup: $popups.showingBottomSecond,
            showingItem: $popups.popupItem,
            showingFirstActionSheet: $actionSheets.showingFirst,
            showingSecondActionSheet: $actionSheets.showingSecond
        )
#else
        PopupsList(
            showingTopFirstFloat: $floats.showingTopFirst,
            showingTopSecondFloat: $floats.showingTopSecond,
            showingBottomFirstFloat: $floats.showingBottomFirst,
            showingBottomSecondFloat: $floats.showingBottomSecond,
            showingTopFirstToast: $toasts.showingTopFirst,
            showingTopSecondToast: $toasts.showingTopSecond,
            showingBottomFirstToast: $toasts.showingBottomFirst,
            showingBottomSecondToast: $toasts.showingBottomSecond,
            showingMiddlePopup: $popups.showingMiddle,
            showingBottomFirstPopup: $popups.showingBottomFirst,
            showingBottomSecondPopup: $popups.showingBottomSecond
        )
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
