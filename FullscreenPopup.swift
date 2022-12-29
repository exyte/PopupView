//
//  FullscreenPopup.swift
//  Pods
//
//  Created by Alisa Mylnikova on 29.12.2022.
//

import Foundation
import SwiftUI

public struct FullscreenPopup<Item: Equatable, PopupContent: View>: ViewModifier {

    // MARK: - Presentaion

    @Binding var isPresented: Bool
    @Binding var item: Item?

    var isBoolMode: Bool

    var sheetPresented: Bool {
        item != nil || isPresented
    }

    // MARK: - Parameters

    var type: Popup<Item, PopupContent>.PopupType
    var position: Popup<Item, PopupContent>.Position

    var animation: Animation

    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// Should close on tap outside - default is `true`
    var closeOnTapOutside: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// is called on any close action
    var dismissCallback: (DismissSource) -> ()

    var view: () -> PopupContent

    // MARK: - Presentation animation

    /// Trigger popup showing/hiding animations and...
    @State private var shouldShowContent = false

    /// ... once hiding animation is finished remove popup from the memory using this flag
    @State private var showContent = false

    /// show transparentNonAnimatingFullScreenCover
    @State private var showSheet = false

    /// opacity of background color
    @State private var opacity = 0.0

    // MARK: - Autohide

    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    private var dispatchWorkHolder = DispatchWorkHolder()

    // MARK: - Internal

    /// Set dismiss souce to pass to dismiss callback
    @State private var dismissSource: DismissSource?

    init(isPresented: Binding<Bool>,
         type: Popup<Item, PopupContent>.PopupType = .`default`,
         position: Popup<Item, PopupContent>.Position = .bottom,
         animation: Animation,
         autohideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         closeOnTapOutside: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping (DismissSource) -> (),
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self._item = .constant(nil)
        self.isBoolMode = true

        self.type = type
        self.position = position
        self.animation = animation
        self.autohideIn = autohideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.closeOnTapOutside = closeOnTapOutside
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    init(item: Binding<Item?>,
         type: Popup<Item, PopupContent>.PopupType = .`default`,
         position: Popup<Item, PopupContent>.Position = .bottom,
         animation: Animation,
         autohideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         closeOnTapOutside: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping (DismissSource) -> (),
         view: @escaping () -> PopupContent) {
        self._isPresented = .constant(false)
        self._item = item
        self.isBoolMode = false

        self.type = type
        self.position = position
        self.animation = animation
        self.autohideIn = autohideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.closeOnTapOutside = closeOnTapOutside
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            boolBody(content: content)
        } else {
            itemBody(content: content)
        }
    }

    func backgroundColorView() -> some View {
        backgroundColor.opacity(opacity)
            .applyIf(closeOnTapOutside) { view in
                view.contentShape(Rectangle())
            }
            .addTapIfNotTV(if: closeOnTapOutside) {
                dismissSource = .tapOutside
                isPresented = false
                item = nil
            }
            .edgesIgnoringSafeArea(.all)
            .animation(.linear(duration: 0.2), value: opacity)
    }

    public func boolBody(content: Content) -> some View {
        content
            .transparentNonAnimatingFullScreenCover(isPresented: $showSheet) {
                backgroundColorView()
                    .modifier(
                        Popup(
                            isPresented: $isPresented,
                            type: type,
                            position: position,
                            animation: animation,
                            autohideIn: autohideIn,
                            dragToDismiss: dragToDismiss,
                            closeOnTap: closeOnTap,
                            closeOnTapOutside: closeOnTapOutside,
                            shouldShowContent: shouldShowContent,
                            showContent: showContent,
                            dismissCallback: { _ in },
                            dismissSource: $dismissSource,
                            animationCompletedCallback: onAnimationCompleted,
                            view: view)
                    )
            }
            .onChange(of: isPresented) { newValue in
                appearAction(sheetPresented: newValue)
            }
    }

    public func itemBody(content: Content) -> some View {
        content
            .transparentNonAnimatingFullScreenCover(isPresented: $showSheet) {
                backgroundColorView()
                    .modifier(
                        Popup(
                            item: $item,
                            type: type,
                            position: position,
                            animation: animation,
                            autohideIn: autohideIn,
                            dragToDismiss: dragToDismiss,
                            closeOnTap: closeOnTap,
                            closeOnTapOutside: closeOnTapOutside,
                            shouldShowContent: shouldShowContent,
                            showContent: showContent,
                            dismissCallback: { _ in },
                            dismissSource: $dismissSource,
                            animationCompletedCallback: onAnimationCompleted,
                            view: view)
                    )
            }
            .onChange(of: item) { newValue in
                appearAction(sheetPresented: newValue != nil)
            }
    }

    func appearAction(sheetPresented: Bool) {
        if sheetPresented {
            dismissSource = nil
            showSheet = true // show transparent fullscreen sheet
            showContent = true // immediately load popup body
            performWithDelay(0.01) {
                shouldShowContent = true // this will cause currentOffset change thus triggering the sliding showing animation
                opacity = 1 // this will cause cross disolving animation for background color
                setupAutohide()
            }
        } else {
            dispatchWorkHolder.work?.cancel()
            shouldShowContent = false // this will cause currentOffset change thus triggering the sliding hiding animation
            opacity = 0
            // do the rest once the animation is finished (see onAnimationCompleted())
            performWithDelay(0.3) { // TEMP: imitate onAnimationCompleted for now
                onAnimationCompleted()
            }
        }
    }

    func onAnimationCompleted() -> () {
        if shouldShowContent { // return if this was called on showing animation, only proceed if called on hiding
            return
        }
        showContent = false // unload popup body after hiding animation is done
        performWithDelay(0.01) {
            showSheet = false
        }
        dismissCallback(dismissSource ?? .binding)
    }

    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            dispatchWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            dispatchWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                dismissSource = .autohide
            })
            if sheetPresented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }
    }

    func performWithDelay(_ delay: Double, block: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }

}
