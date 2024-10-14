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

    var popupPresented: Bool {
        item != nil || isPresented
    }

    // MARK: - Parameters

    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Should close on tap outside - default is `false`
    var closeOnTapOutside: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// Custom background view for outside area
    var backgroundView: AnyView?

    /// If opaque - taps do not pass through popup's background color
    var isOpaque: Bool

    /// called when when dismiss animation starts
    var userWillDismissCallback: (DismissSource) -> ()

    /// called when when dismiss animation ends
    var userDismissCallback: (DismissSource) -> ()

    var params: Popup<PopupContent>.PopupParameters

    var view: (() -> PopupContent)!
    var itemView: ((Item) -> PopupContent)!

    // MARK: - Presentation animation

    /// Trigger popup showing/hiding animations and...
    @State private var shouldShowContent = false

    /// ... once hiding animation is finished remove popup from the memory using this flag
    @State private var showContent = false

    /// keep track of closing state to avoid unnecessary showing bug
    @State private var closingIsInProcess = false

    /// show transparentNonAnimatingFullScreenCover
    @State private var showSheet = false

    /// opacity of background color
    @State private var opacity = 0.0

    /// A temporary variable to hold a copy of the `itemView` when the item is nil (to complete `itemView`'s dismiss animation)
    @State private var tempItemView: PopupContent?

    // MARK: - Autohide

    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    @State private var dispatchWorkHolder = DispatchWorkHolder()

    // MARK: - Internal

    /// Set dismiss source to pass to dismiss callback
    @State private var dismissSource: DismissSource?

    /// Synchronize isPresented changes and animations
    private let eventsQueue = DispatchQueue(label: "eventsQueue", qos: .utility)
    @State private var eventsSemaphore = DispatchSemaphore(value: 1)

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         isBoolMode: Bool,
         params: Popup<PopupContent>.PopupParameters,
         view: (() -> PopupContent)?,
         itemView: ((Item) -> PopupContent)?) {
        self._isPresented = isPresented
        self._item = item
        self.isBoolMode = isBoolMode

        self.params = params
        self.autohideIn = params.autohideIn
        self.closeOnTapOutside = params.closeOnTapOutside
        self.backgroundColor = params.backgroundColor
        self.backgroundView = params.backgroundView
        self.isOpaque = params.isOpaque
        self.userDismissCallback = params.dismissCallback
        self.userWillDismissCallback = params.willDismissCallback

        if let view = view {
            self.view = view
        }
        if let itemView = itemView {
            self.itemView = itemView
        }

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content: content)
                .onChange(of: isPresented) { newValue in
                    eventsQueue.async {
                        DispatchQueue.main.async {
                            eventsSemaphore.wait()
                            closingIsInProcess = !newValue
                            appearAction(popupPresented: newValue)
                        }
                    }
                }
                .onAppear {
                    if isPresented {
                        appearAction(popupPresented: true)
                    }
                }
        } else {
            main(content: content)
                .onChange(of: item) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        self.closingIsInProcess = newValue == nil
                        if let newValue {
                            /// copying `itemView`
                            self.tempItemView = itemView(newValue)
                        }
                        appearAction(popupPresented: newValue != nil)
                    }
                }
                .onAppear {
                    if let item {
                        self.tempItemView = itemView(item)
                        appearAction(popupPresented: true)
                    }
                }
        }
    }

    @ViewBuilder
    public func main(content: Content) -> some View {
        if isOpaque {
#if os(iOS)
            content.transparentNonAnimatingFullScreenCover(isPresented: $showSheet, dismissSource: dismissSource, userDismissCallback: userDismissCallback) {
                constructPopup()
            }
#else
            ZStack {
                content
                constructPopup()
            }
#endif
        } else {
            ZStack {
                content
                constructPopup()
            }
        }
    }

    func createBackgroundView() -> some View {
        Group {
            if let backgroundView = backgroundView {
                backgroundView
            } else {
                backgroundColor
            }
        }
        .opacity(opacity)
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
                createBackgroundView()
                    .modifier(getModifier())
            }
        }
    }

    var viewForItem: (() -> PopupContent)? {
        if let item = item {
            return { itemView(item) }
        } else if let tempItemView {
            return { tempItemView }
        }
        return nil
    }

    private func getModifier() -> Popup<PopupContent> {
        Popup(
            params: params,
            view: viewForItem != nil ? viewForItem! : view,
            popupPresented: popupPresented,
            shouldShowContent: shouldShowContent,
            showContent: showContent,
            positionIsCalculatedCallback: {
                // once the closing has been started, don't allow position recalculation to trigger popup shpwing again
                if !closingIsInProcess {
                    DispatchQueue.main.async {
                        shouldShowContent = true // this will cause currentOffset change thus triggering the sliding showing animation
                        opacity = 1 // this will cause cross disolving animation for background color
                    }
                    setupAutohide()
                }
            },
            animationCompletedCallback: onAnimationCompleted,
            dismissCallback: { source in
                dismissSource = source
                isPresented = false
                item = nil
            }
        )
    }

    func appearAction(popupPresented: Bool) {
        if popupPresented {
            dismissSource = nil
            showSheet = true // show transparent fullscreen sheet
            showContent = true // immediately load popup body
            // shouldShowContent is set after popup's frame is calculated, see positionIsCalculatedCallback
        } else {
            closingIsInProcess = true
            userWillDismissCallback(dismissSource ?? .binding)
            dispatchWorkHolder.work?.cancel()
            shouldShowContent = false // this will cause currentOffset change thus triggering the sliding hiding animation
            opacity = 0
            // do the rest once the animation is finished (see onAnimationCompleted())
        }

        if #unavailable(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0) {
            performWithDelay(0.3) { // imitate onAnimationCompleted for older os
                onAnimationCompleted()
            }
        }
    }

    func onAnimationCompleted() -> () {
        if shouldShowContent { // return if this was called on showing animation, only proceed if called on hiding
            eventsSemaphore.signal()
            return
        }
        showContent = false // unload popup body after hiding animation is done
        tempItemView = nil
        performWithDelay(0.01) {
            showSheet = false
        }
        if !isOpaque { // for opaque this callback is called in fullScreenCover's onDisappear
            userDismissCallback(dismissSource ?? .binding)
        }

        eventsSemaphore.signal()
    }

    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            dispatchWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            dispatchWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                dismissSource = .autohide
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                dispatchWorkHolder.work = nil
            })
            if popupPresented, let work = dispatchWorkHolder.work {
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
