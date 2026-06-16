//
//  FullscreenPopup.swift
//  Pods
//
//  Created by Alisa Mylnikova on 29.12.2022.
//

import Foundation
import SwiftUI

@MainActor
public struct PopupModifier<Item: Equatable, PopupContent: View>: ViewModifier {

    // MARK: - Presentation

    @State var id = UUID()

    @Binding var isPresented: Bool
    @Binding var item: Item?

    var isBoolMode: Bool
    var params: Popup.BasePopupParameters

    var view: (() -> PopupContent)!
    var itemView: ((Item) -> PopupContent)!

    var popupPresented: Bool {
        item != nil || isPresented
    }

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
    @State private var animatableOpacity: CGFloat = 0

    /// A temporary variable to hold a copy of the `itemView` when the item is nil (to complete `itemView`'s dismiss animation)
    @State private var tempItemView: PopupContent?

    /// The rect of hosting content
    @State private var presenterContentRect: CGRect = .zero
    /// The rect of popup content
    @State private var sheetContentRect: CGRect = .zero

    // MARK: - Autohide

    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    @State private var autohidingWorkHolder = DispatchWorkHolder()

    /// holder for `dismissibleIn` dispatch work (to be able to cancel it when needed)
    @State private var dismissibleInWorkHolder = DispatchWorkHolder()

    // MARK: - Autohide With Dragging
    /// If user "grabbed" the popup to drag it around, put off the autohiding until he lifts his finger up

    /// is user currently holding th popup with his finger
    @State private var isDragging = false

    /// if autohide time was set up, shows that timer has come to an end already
    @State private var timeToHide = false

    // MARK: - dismissibleIn

    private var dismissEnabledRef: ClassReference<Binding<Bool>>?

    // MARK: - Internal

    /// Set dismiss source to pass to dismiss callback
    @State private var dismissSource: Popup.DismissSource?

    /// Synchronize isPresented changes and animations
    private let eventsQueue = DispatchQueue(label: "eventsQueue", qos: .utility)
    @State private var eventsSemaphore = DispatchSemaphore(value: 1)

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         isBoolMode: Bool,
         params: Popup.BasePopupParameters,
         view: (() -> PopupContent)?,
         itemView: ((Item) -> PopupContent)?) {
        self._isPresented = isPresented
        self._item = item
        self.isBoolMode = isBoolMode

        self.params = params

        if let view {
            self.view = view
        }
        if let itemView {
            self.itemView = itemView
        }

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
        self.dismissEnabledRef = ClassReference(params.dismissEnabled)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content)
                .onChange(of: isPresented) {
                    eventsQueue.async { [eventsSemaphore] in
                        eventsSemaphore.wait()
                        DispatchQueue.main.async {
                            closingIsInProcess = !isPresented
                            appearAction(popupPresented: isPresented)
                        }
                    }
                }
                .onAppear {
                    if isPresented {
                        appearAction(popupPresented: true)
                    }
                }
        } else {
            main(content)
                .onChange(of: item) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        self.closingIsInProcess = item == nil
                        if let item {
                            /// copying `itemView`
                            self.tempItemView = itemView(item)
                        }
                        appearAction(popupPresented: item != nil)

                        #if os(iOS)
                        if params.displayMode == .window, showSheet, item != nil {
                            WindowManager.updateRootView(id: id, dismissClosure: {
                                dismissSource = .binding
                                isPresented = false
                                item = nil
                            }) {
                                popupWithBackground()
                            }
                        }
                        #endif
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
    public func main(_ presenterContent: Content) -> some View {
        presenterContentWithPopup(presenterContent)
            .frameGetter($presenterContentRect)
            .onChange(of: sheetContentRect) {
                // do not launch actual animation until off screen layouting is done
                guard sheetContentRect.height != 0 else { return }
                // once the closing has been started, don't allow position recalculation to trigger popup showing again
                guard !closingIsInProcess else { return }

                DispatchQueue.main.async {
                    shouldShowContent = true // this will cause currentOffset change thus triggering the sliding showing animation
                    withAnimation(.linear(duration: 0.2)) {
                        animatableOpacity = 1 // this will cause cross dissolving animation for background color/view
                    }
                }
                setupAutohide()
                setupDismissibleIn()
            }
    }

    @ViewBuilder
    public func presenterContentWithPopup(_ presenterContent: Content) -> some View {
#if os(iOS)
        switch params.displayMode {
        case .overlay:
            presenterContent
                .overlay {
                    if showSheet {
                        popupWithBackground()
                    }
                }

        case .sheet:
            presenterContent.transparentNonAnimatingFullScreenCover(isPresented: $showSheet, dismissSource: dismissSource, userDismissCallback: params.dismissCallback) {
                popupWithBackground()
            }

        case .window:
            presenterContent
                .onChange(of: showSheet) {
                    if showSheet {
                        WindowManager.showInNewWindow(
                            id: id,
                            closeOnTapOutside: params.closeOnTapOutside,
                            allowTapThroughBG: params.allowTapThroughBG,
                            dismissClosure: {
                                dismissSource = .binding
                                isPresented = false
                                item = nil
                            }) {
                                popupWithBackground()
                            }
                    } else {
                        WindowManager.closeWindow(id: id)
                    }
                }
                .onDisappear {
                    WindowManager.closeWindow(id: id)
                }
        }
#elseif os(macOS) || os(tvOS)
        ZStack {
            presenterContent
                .disabled(showContent)

            popupWithBackground()
        }
        .onExitCommand {
            dismissSource = .exitCommand
            isPresented = false
            item = nil
        }
#else
        ZStack {
            presenterContent
                .disabled(showContent)

            popupWithBackground()
        }
#endif
    }

    @ViewBuilder
    func popupWithBackground() -> some View {
        ZStack {
            popupBackground()
            if params.displayMode == .window {
                BGHitRegion()
            }
            popupBody()
                .frameGetter($sheetContentRect)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func popupBody() -> some View {
        var viewForItem: (() -> PopupContent)? {
            if let item = item {
                return { itemView(item) }
            } else if let tempItemView {
                return { tempItemView }
            }
            return nil
        }

        PopupBody(
            shouldShowContent: $shouldShowContent,
            showContent: $showContent,
            presenterContentRect: $presenterContentRect,
            sheetContentRect: $sheetContentRect,
            isDragging: $isDragging,
            timeToHide: $timeToHide,
            params: params,
            popupBodyBuilder: viewForItem != nil ? viewForItem! : view,
            dismissCallback: { source in
                dismissSource = source
                isPresented = false
                item = nil
            }
        )
    }

    private func popupBackground() -> some View {
        PopupBackgroundView(
            animatableOpacity: $animatableOpacity,
            shouldDismiss: {
                dismissSource = .tapOutside
                isPresented = false
                item = nil
            },
            isWindowMode: params.displayMode == .window,
            backgroundColor: params.backgroundColor,
            backgroundView: params.backgroundView,
            closeOnTapOutside: params.closeOnTapOutside,
            allowTapThroughBG: params.allowTapThroughBG,
            dismissEnabled: params.dismissEnabled
        )
    }

    func appearAction(popupPresented: Bool) {
        if popupPresented {
            dismissSource = nil
            showSheet = true // show transparent fullscreen sheet
            showContent = true // immediately load popup body
            // shouldShowContent is set after popup's frame is calculated, see .onChange(of: sheetContentRect)
        } else {
            closingIsInProcess = true
            params.willDismissCallback(dismissSource ?? .binding)
            autohidingWorkHolder.work?.cancel()
            dismissibleInWorkHolder.work?.cancel()
            shouldShowContent = false // this will cause currentOffset change thus triggering the sliding hiding animation
            animatableOpacity = 0
            // do the rest once the animation is finished (see onAnimationCompleted())
        }

        // animation completion block isn't being called reliably when there are other animations happening at the same time (drag, autohide, etc.) so here we imitate onAnimationCompleted
        performWithDelay(0.3) {
            onAnimationCompleted()
        }
    }

    func onAnimationCompleted() {
        if shouldShowContent { // return if this was called on showing animation, only proceed if called on hiding
            eventsSemaphore.signal()
            return
        }
        showContent = false // unload popup body after hiding animation is done
        tempItemView = nil
        if params.dismissibleIn != nil {
            params.dismissEnabled.wrappedValue = false
        }
        performWithDelay(0.01) {
            showSheet = false
            sheetContentRect = .zero
        }
        if params.displayMode != .sheet { // for .sheet this callback is called in fullScreenCover's onDisappear
            params.dismissCallback(dismissSource ?? .binding)
        }

        eventsSemaphore.signal()
    }

    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = params.autohideIn {
            autohidingWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            autohidingWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                if isDragging {
                    timeToHide = true // raise this flag to hide the popup once the drag is over
                    return
                }
                dismissSource = .autohide
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                autohidingWorkHolder.work = nil
            })
            if popupPresented, let work = autohidingWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }
    }

    func setupDismissibleIn() {
        if let dismissibleIn = params.dismissibleIn {
            dismissibleInWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            dismissibleInWorkHolder.work = DispatchWorkItem(block: { [weak dismissEnabledRef] in
                dismissEnabledRef?.value.wrappedValue = true
                dismissibleInWorkHolder.work = nil
            })
            if popupPresented, let work = dismissibleInWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissibleIn, execute: work)
            }
        }
    }

    func performWithDelay(_ delay: Double, block: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
}
