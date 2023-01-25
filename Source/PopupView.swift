//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

public enum DismissSource {
    case binding // set isPresented to false ot item to nil
    case tapInside
    case tapOutside
    case drag
    case autohide
}

public struct Popup<Item: Equatable, PopupContent: View>: ViewModifier {

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         params: Popup<Item, PopupContent>.PopupParameters,
         view: @escaping () -> PopupContent,
         shouldShowContent: Bool = true,
         showContent: Bool = true,
         dismissSource: Binding<DismissSource?>,
         animationCompletedCallback: @escaping () -> ()) {

        self._isPresented = isPresented
        self._item = item

        self.type = params.type
        self.position = params.position
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.closeOnTap = params.closeOnTap
        self.isOpaque = params.isOpaque

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self._dismissSource = dismissSource
        self.animationCompletedCallback = animationCompletedCallback
    }
    
    public enum PopupType {

        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)

        func shouldBeCentered() -> Bool {
            switch self {
            case .`default`:
                return true
            default:
                return false
            }
        }
    }

    public enum Position {
        case top
        case bottom
    }

    public struct PopupParameters {
        var type: PopupType = .default

        var position: Position = .bottom

        var animation: Animation = .easeOut(duration: 0.3)

        /// If nil - never hides on its own
        var autohideIn: Double?

        /// Should allow dismiss by dragging
        var dragToDismiss: Bool = true

        /// Should close on tap - default is `true`
        var closeOnTap: Bool = true

        /// Should close on tap outside - default is `true`
        var closeOnTapOutside: Bool = false

        /// Background color for outside area
        var backgroundColor: Color = .clear

        /// If true taps do not pass through popup's background and the popup is displayed on top of navbar. Always opaque if closeOnTapOutside is true
        var isOpaque: Bool = false

        var dismissCallback: (DismissSource) -> () = {_ in}

        public func type(_ type: PopupType) -> PopupParameters {
            var params = self
            params.type = type
            return params
        }

        public func position(_ position: Position) -> PopupParameters {
            var params = self
            params.position = position
            return params
        }

        public func animation(_ animation: Animation) -> PopupParameters {
            var params = self
            params.animation = animation
            return params
        }

        public func autohideIn(_ autohideIn: Double?) -> PopupParameters {
            var params = self
            params.autohideIn = autohideIn
            return params
        }

        public func dragToDismiss(_ dragToDismiss: Bool) -> PopupParameters {
            var params = self
            params.dragToDismiss = dragToDismiss
            return params
        }

        public func closeOnTap(_ closeOnTap: Bool) -> PopupParameters {
            var params = self
            params.closeOnTap = closeOnTap
            return params
        }

        public func closeOnTapOutside(_ closeOnTapOutside: Bool) -> PopupParameters {
            var params = self
            params.closeOnTapOutside = closeOnTapOutside
            return params
        }

        public func backgroundColor(_ backgroundColor: Color) -> PopupParameters {
            var params = self
            params.backgroundColor = backgroundColor
            return params
        }

        public func isOpaque(_ isOpaque: Bool) -> PopupParameters {
            var params = self
            params.isOpaque = isOpaque
            return params
        }

        public func dismissSourceCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = dismissCallback
            return params
        }

        public func dismissCallback(_ dismissCallback: @escaping () -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = { _ in
                dismissCallback()
            }
            return params
        }
    }

    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool
    @Binding var item: Item?

    var type: PopupType
    var position: Position

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// If opaque taps do not pass through popup's background color. Always opaque if closeOnTapOutside is true
    var isOpaque: Bool

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Bool

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// Set dismiss souce to pass to dismiss callback
    @Binding private var dismissSource: DismissSource?

    /// called on showing/hiding sliding animation completed
    var animationCompletedCallback: () -> ()

    var view: () -> PopupContent

    // MARK: - Private Properties

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero

    /// The rect and safe area of popup content
    @State private var sheetContentRect: CGRect = .zero

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGFloat = 0
    
    /// The offset when the popup is displayed - without this offset they'd be exactly in the middle
    private var displayedOffset: CGFloat {
        if isOpaque {
            switch type {
            case .`default`:
                return 0
            case .toast:
                if position == .bottom {
                    return screenHeight/2 - sheetContentRect.height/2
                } else {
                    return -screenHeight/2 + sheetContentRect.height/2
                }
            case .floater(let verticalPadding, let useSafeAreaInset):
                if position == .bottom {
                    return screenHeight/2 - sheetContentRect.height/2 - verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0)
                } else {
                    return -screenHeight/2 + sheetContentRect.height/2 + verticalPadding + (useSafeAreaInset ? safeAreaInsets.top : 0)
                }
            }
        }

        switch type {
        case .`default`:
            return -presenterContentRect.midY + screenHeight/2
        case .toast:
            if position == .bottom {
                return presenterContentRect.minY + safeAreaInsets.bottom + presenterContentRect.height - presenterContentRect.midY - sheetContentRect.height/2
            } else {
                return presenterContentRect.minY - safeAreaInsets.top - presenterContentRect.midY + sheetContentRect.height/2
            }
        case .floater(let verticalPadding, let useSafeAreaInset):
            if position == .bottom {
                return presenterContentRect.minY + safeAreaInsets.bottom + presenterContentRect.height - presenterContentRect.midY - sheetContentRect.height/2 - verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0)
            } else {
                return presenterContentRect.minY - safeAreaInsets.top - presenterContentRect.midY + sheetContentRect.height/2 + verticalPadding + (useSafeAreaInset ? safeAreaInsets.top : 0)
            }
        }
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if position == .top {
            if presenterContentRect.isEmpty {
                return -1000
            }
            return -presenterContentRect.midY - sheetContentRect.height/2 - 5
        } else {
            if presenterContentRect.isEmpty {
                return 1000
            }
            return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return shouldShowContent ? displayedOffset : hiddenOffset
    }

    private var screenSize: CGSize {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
        #else
        return NSScreen.main?.frame.size ?? .zero
        #endif
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        content
            .frameGetter($presenterContentRect)
            .overlay(
                Group {
                    if showContent {
                        sheet()
                    }
                }
            )
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {
        let sheet = ZStack {
            self.view()
                .addTapIfNotTV(if: closeOnTap) {
                    dismissSource = .tapInside
                    dismiss()
                }
                .frameGetter($sheetContentRect)
                .offset(y: currentOffset)
                .onAnimationCompleted(for: currentOffset) {
                    //animationCompletedCallback() TEMP: need to fix
                }
                .animation(animation, value: currentOffset)
        }

        #if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet
            .applyIf(dragToDismiss) {
                $0.offset(y: dragOffset())
                    .simultaneousGesture(drag)
            }
        #else
        return sheet
        #endif
    }

    #if !os(tvOS)
    func dragOffset() -> CGFloat {
        if (position == .bottom && dragState.translation.height > 0) ||
           (position == .top && dragState.translation.height < 0) {
            return dragState.translation.height
        }
        return lastDragPosition
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let reference = sheetContentRect.height / 3
        if (position == .bottom && drag.translation.height > reference) ||
            (position == .top && drag.translation.height < -reference) {
            lastDragPosition = drag.translation.height
            withAnimation {
                lastDragPosition = 0
            }
            dismissSource = .drag
            dismiss()
        }
    }
    #endif
    
    private func dismiss() {
        isPresented = false
        item = nil
    }
}
