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
            .popup(isPresented: $floats.showingTopFirst, type: .floater(), position: .top, animation: .spring()) {
                FloatTopFirst()
            }
            .popup(isPresented: $floats.showingTopSecond, type: .floater(), position: .top, animation: .spring(), autohideIn: 3) {
                FloatTopSecond()
            }
            .popup(isPresented: $floats.showingBottomFirst, type: .floater(), position: .bottom, animation: .spring(), autohideIn: 2) {
                FloatBottomFirst()
            }
            .popup(isPresented: $floats.showingBottomSecond, type: .floater(), position: .bottom, animation: .spring(), autohideIn: 5) {
                FloatBottomSecond()
            }
        
        // MARK: - Designed toasts
            .popup(isPresented: $toasts.showingTopFirst, type: .toast, position: .top) {
                ToastTopFirst()
            }
            .popup(isPresented: $toasts.showingTopSecond, type: .toast, position: .top) {
                ToastTopSecond()
            }
            .popup(isPresented: $toasts.showingBottomFirst, type: .toast, position: .bottom, closeOnTap: false, backgroundColor: .black.opacity(0.4)) {
                ToastBottomFirst(isShowing: $toasts.showingBottomFirst)
            }
            .popup(isPresented: $toasts.showingBottomSecond, type: .toast, position: .bottom, autohideIn: 10) {
                ToastBottomSecond()
            }
        
        // MARK: - Designed popups
            .popup(isPresented: $popups.showingMiddle, type: .`default`, closeOnTap: false, backgroundColor: .black.opacity(0.4)) {
                PopupMiddle(isPresented: $popups.showingMiddle)
            }
            .popup(isPresented: $popups.showingBottomFirst, type: .floater(), position: .bottom, closeOnTap: false, backgroundColor: .black.opacity(0.4)) {
                PopupBottomFirst(isPresented: $popups.showingBottomFirst)
            }
            .popup(isPresented: $popups.showingBottomSecond, type: .floater(verticalPadding: 0, useSafeAreaInset: false), position: .bottom, closeOnTapOutside: true, backgroundColor: .black.opacity(0.4)) {
                PopupBottomSecond()
            }
        
#if os(iOS)
        // MARK: - Designed action sheets
        return commonView
            .popup(isPresented: $actionSheets.showingFirst, type: .toast, position: .bottom, closeOnTap: false, backgroundColor: .black.opacity(0.4)) {
                ActionSheetFirst()
            }
            .popup(isPresented: $actionSheets.showingSecond, type: .toast, position: .bottom, closeOnTap: false, backgroundColor: .black.opacity(0.4)) {
                ActionSheetSecond()
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
