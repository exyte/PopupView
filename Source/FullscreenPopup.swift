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

    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Should close on tap outside - default is `true`
    var closeOnTapOutside: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// If opaque taps do not pass through popup's background color. Always opaque if closeOnTapOutside is true
    var isOpaque: Bool

    /// Is called on any close action
    var dismissCallback: (DismissSource) -> ()

    var params: Popup<Item, PopupContent>.PopupParameters

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

    var opaqueBackground: Bool {
        isOpaque || closeOnTapOutside
    }

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         isBoolMode: Bool,
         params: Popup<Item, PopupContent>.PopupParameters,
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self._item = item
        self.isBoolMode = isBoolMode

        self.params = params
        self.autohideIn = params.autohideIn
        self.closeOnTapOutside = params.closeOnTapOutside
        self.backgroundColor = params.backgroundColor
        self.isOpaque = params.isOpaque
        self.dismissCallback = params.dismissCallback

        self.view = view

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content: content)
                .onChange(of: isPresented) { newValue in
                    appearAction(sheetPresented: newValue)
                }
        } else {
            main(content: content)
                .onChange(of: item) { newValue in
                    appearAction(sheetPresented: newValue != nil)
                }
        }
    }

    public func main(content: Content) -> some View {
        content
            .applyIf(opaqueBackground) { body in
                body.transparentNonAnimatingFullScreenCover(isPresented: $showSheet) {
                    constructPopup()
                }
            }
            .applyIf(!opaqueBackground) { body in
                ZStack {
                    body
                    constructPopup()
                }
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

    func constructPopup() -> some View {
        Group {
            if showContent {
                backgroundColorView()
                    .modifier(
                        Popup(
                            isPresented: $isPresented,
                            params: params,
                            view: view,
                            shouldShowContent: shouldShowContent,
                            showContent: showContent,
                            dismissSource: $dismissSource,
                            animationCompletedCallback: onAnimationCompleted)
                    )
            }
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
