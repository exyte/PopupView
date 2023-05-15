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

public struct Popup<PopupContent: View>: ViewModifier {

    init(params: Popup<PopupContent>.PopupParameters,
         view: @escaping () -> PopupContent,
         shouldShowContent: Bool = true,
         showContent: Bool = true,
         animationCompletedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.type = params.type
        self.position = params.position
        self.appearFrom = params.appearFrom
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.closeOnTap = params.closeOnTap
        self.opaqueBackground = params.isOpaque || params.closeOnTapOutside

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self.animationCompletedCallback = animationCompletedCallback
        self.dismissCallback = dismissCallback
    }
    
    public enum PopupType {
        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)
    }

    public enum Position {
        case top
        case bottom
    }

    public enum AppearFrom {
        case top
        case bottom
        case left
        case right
    }

    public struct PopupParameters {
        var type: PopupType = .default

        var position: Position = .bottom

        var appearFrom: AppearFrom?

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

        /// Custom background view for outside area
        var backgroundView: AnyView?

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

        public func appearFrom(_ appearFrom: AppearFrom) -> PopupParameters {
            var params = self
            params.appearFrom = appearFrom
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

        public func backgroundView<BackgroundView: View>(_ backgroundView: ()->(BackgroundView)) -> PopupParameters {
            var params = self
            params.backgroundView = AnyView(backgroundView())
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

    var type: PopupType
    var position: Position
    var appearFrom: AppearFrom?

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// If opaque taps do not pass through popup's background color. True if either closeOnTapOutside or isOpaque is true
    var opaqueBackground: Bool

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Bool

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// called on showing/hiding sliding animation completed
    var animationCompletedCallback: () -> ()

    /// Call dismiss callback with dismiss source
    var dismissCallback: (DismissSource)->()

    var view: () -> PopupContent

    // MARK: - Private Properties

    @StateObject var keyboardHeightHelper = KeyboardHeightHelper()

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero

    /// The rect and safe area of popup content
    @State private var sheetContentRect: CGRect = .zero

    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGFloat = 0
    
    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if opaqueBackground {
            switch type {
            case .`default`:
                return (screenHeight - sheetContentRect.height)/2 - safeAreaInsets.top
            case .toast:
                if position == .bottom {
                    return screenHeight - sheetContentRect.height - keyboardHeightHelper.keyboardHeight - safeAreaInsets.top
                } else {
                    return -safeAreaInsets.top
                }
            case .floater(let verticalPadding, let useSafeAreaInset):
                if position == .bottom {
                    return screenHeight - sheetContentRect.height - keyboardHeightHelper.keyboardHeight - verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0) - safeAreaInsets.top
                } else {
                    return verticalPadding + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
                }
            }
        }

        switch type {
        case .`default`:
            return (presenterContentRect.height - sheetContentRect.height)/2
        case .toast:
            if position == .bottom {
                return presenterContentRect.height - sheetContentRect.height + safeAreaInsets.bottom + (keyboardHeightHelper.keyboardDisplayed ? -safeAreaInsets.bottom : 0)
            } else {
                return -safeAreaInsets.top
            }
        case .floater(let verticalPadding, let useSafeAreaInset):
            if position == .bottom {
                return presenterContentRect.height - sheetContentRect.height + safeAreaInsets.bottom + verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0) - 28
            } else {
                return verticalPadding + (useSafeAreaInset ? 0 : -safeAreaInsets.top)
            }
        }
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        let from: AppearFrom
        if let appearFrom = appearFrom {
            from = appearFrom
        }
        else {
            from = position == .top ? .top : .bottom
        }

        switch from {
        case .top:
            if sheetContentRect.isEmpty {
                return CGPoint(x: 0, y: -screenHeight * 2)
            }
            return CGPoint(x: 0, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottom:
            if sheetContentRect.isEmpty {
                return CGPoint(x: 0, y: screenHeight * 2)
            }
            return CGPoint(x: 0, y: screenHeight)
        case .left:
            return CGPoint(x: -screenSize.width, y: displayedOffsetY)
        case .right:
            return CGPoint(x: screenSize.width, y: displayedOffsetY)
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGPoint {
        return shouldShowContent ? CGPoint(x: 0, y: displayedOffsetY) : hiddenOffset
    }

    private var screenSize: CGSize {
#if os(iOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#else
        return CGSize(width: presenterContentRect.size.width, height: presenterContentRect.size.height - presenterContentRect.minY)
#endif
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        content
            .frameGetter($presenterContentRect)
            .safeAreaGetter($safeAreaInsets)
            .overlay(
                Group {
                    if showContent, presenterContentRect != .zero {
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
                    dismissCallback(.tapInside)
                }
                .frameGetter($sheetContentRect)
                .position(x: (screenSize.width - safeAreaInsets.leading - safeAreaInsets.trailing)/2 + currentOffset.x, y: sheetContentRect.height/2 + currentOffset.y)
                //.onAnimationCompleted(for: currentOffset) {
                    //animationCompletedCallback() TEMP: need to fix
                //}
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
            dismissCallback(.drag)
        }
    }
#endif
}
