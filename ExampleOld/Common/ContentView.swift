//
//  ContentView.swift
//  Example
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import ExytePopupView

class SomeItem: Equatable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    static func == (lhs: SomeItem, rhs: SomeItem) -> Bool {
        lhs.value == rhs.value
    }
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

struct ContentView : View {
    @State var floats = ToastsState()
    @State var toasts = ToastsState()
    @State var popups = PopupsState()
    @State var actionSheets = ActionSheetsState()

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

        // MARK: - Designed popups

            .popup(item: $popups.middleItem) { item in
                PopupMiddle(item: item) {
                    popups.middleItem = nil
                }
            } customize: {
                $0
                    .closeOnTap(false)
                    .backgroundColor(.black.opacity(0.4))
            }

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
            middleItem: $popups.middleItem,
            showingBottomFirstPopup: $popups.showingBottomFirst,
            showingBottomSecondPopup: $popups.showingBottomSecond,
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
            middleItem: $popups.middleItem,
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
