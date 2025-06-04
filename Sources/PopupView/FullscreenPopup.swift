//
//  FullscreenPopup.swift
//  Pods
//
//  Created by Alisa Mylnikova on 29.12.2022.
//

import Foundation
import SwiftUI

@MainActor
public struct FullscreenPopup<Item: Equatable, PopupContent: View>: ViewModifier {

    // MARK: - Presentation

    @State var id = UUID()

    @Binding var isPresented: Bool
    @Binding var item: Item?

    var isBoolMode: Bool

    var popupPresented: Bool {
        item != nil || isPresented
    }

    // MARK: - Parameters

    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Only allow dismiss by any means after this time passes
    var dismissibleIn: Double?

    /// Becomes true when `dismissibleIn` times finishes
    /// Makes no sense if `dismissibleIn` is nil
    var dismissEnabled: Binding<Bool>

    /// Should close on tap outside - default is `false`
    var closeOnTapOutside: Bool

    /// Should allow taps to pass "through" the popup's background down to views "below" it.
    /// .sheet popup is always allowTapThroughBG = false
    var allowTapThroughBG: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// Custom background view for outside area
    var backgroundView: AnyView?

    /// If opaque - taps do not pass through popup's background color
    var displayMode: Popup<PopupContent>.DisplayMode

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
    @State private var animatableOpacity: CGFloat = 0

    /// A temporary variable to hold a copy of the `itemView` when the item is nil (to complete `itemView`'s dismiss animation)
    @State private var tempItemView: PopupContent?

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
        self.dismissibleIn = params.dismissibleIn
        self.dismissEnabled = params.dismissEnabled
        self.closeOnTapOutside = params.closeOnTapOutside
        self.allowTapThroughBG = params.allowTapThroughBG
        self.backgroundColor = params.backgroundColor
        self.backgroundView = params.backgroundView
        self.displayMode = params.displayMode
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
        self.dismissEnabledRef = ClassReference(self.dismissEnabled)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content: content)
                .onChange(of: isPresented) { newValue in
                    eventsQueue.async { [eventsSemaphore] in
                        eventsSemaphore.wait()
                        DispatchQueue.main.async {
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
#if os(iOS)
        switch displayMode {
        case .overlay:
            ZStack {
                content
                constructPopup()
            }

        case .sheet:
            content.transparentNonAnimatingFullScreenCover(isPresented: $showSheet, dismissSource: dismissSource, userDismissCallback: userDismissCallback) {
                constructPopup()
            }

        case .window:
            content
                .onChange(of: showSheet) { newValue in
                    if newValue {
                        WindowManager.showInNewWindow(id: id, allowTapThroughBG: allowTapThroughBG, dismissClosure: {
                            dismissSource = .binding
                            isPresented = false
                            item = nil
                        }) {
                            constructPopup()
                        }
                    } else {
                        WindowManager.closeWindow(id: id)
                    }
                }
        }
#else
            ZStack {
                content
                constructPopup()
            }
#endif
    }
    
    @ViewBuilder
    func constructPopup() -> some View {
        if showContent {
            PopupBackgroundView(
                id: $id,
                isPresented: $isPresented,
                item: $item,
                animatableOpacity: $animatableOpacity,
                dismissSource: $dismissSource,
                backgroundColor: backgroundColor,
                backgroundView: backgroundView,
                closeOnTapOutside: closeOnTapOutside,
                allowTapThroughBG: allowTapThroughBG,
                dismissEnabled: dismissEnabled
            )
            .modifier(getModifier())
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
            shouldShowContent: $shouldShowContent,
            showContent: showContent,
            isDragging: $isDragging,
            timeToHide: $timeToHide,
            positionIsCalculatedCallback: {
                // once the closing has been started, don't allow position recalculation to trigger popup showing again
                if !closingIsInProcess {
                    DispatchQueue.main.async {
                        shouldShowContent = true // this will cause currentOffset change thus triggering the sliding showing animation
                        withAnimation(.linear(duration: 0.2)) {
                            animatableOpacity = 1 // this will cause cross dissolving animation for background color/view
                        }
                    }
                    setupAutohide()
                    setupdismissibleIn()
                }
            },
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
        if dismissibleIn != nil {
            dismissEnabled.wrappedValue = false
        }
        performWithDelay(0.01) {
            showSheet = false
        }
        if displayMode != .sheet { // for .sheet this callback is called in fullScreenCover's onDisappear
            userDismissCallback(dismissSource ?? .binding)
        }

        eventsSemaphore.signal()
    }

    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
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

    func setupdismissibleIn() {
        if let dismissibleIn = dismissibleIn {
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
