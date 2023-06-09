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

        self.position = params.position ?? params.type.defaultPosition
        self.appearFrom = params.appearFrom
        self.verticalPadding = params.type.verticalPadding
        self.horizontalPadding = params.type.horizontalPadding
        self.useSafeAreaInset = params.type.useSafeAreaInset
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
        case floater(verticalPadding: CGFloat = 10, horizontalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)

        var defaultPosition: Position {
            if case .default = self {
                return .center
            }
            return .bottom
        }

        var verticalPadding: CGFloat {
            if case let .floater(verticalPadding, _, _) = self {
                return verticalPadding
            }
            return 0
        }

        var horizontalPadding: CGFloat {
            if case let .floater(_, horizontalPadding, _) = self {
                return horizontalPadding
            }
            return 0
        }

        var useSafeAreaInset: Bool {
            if case let .floater(_, _, use) = self {
                return use
            }
            return false
        }
    }

    public enum Position {
        case topLeading
        case top
        case topTrailing

        case leading
        case center // usual popup
        case trailing

        case bottomLeading
        case bottom
        case bottomTrailing

        var isTop: Bool {
            [.topLeading, .top, .topTrailing].contains(self)
        }

        var isVerticalCenter: Bool {
            [.leading, .center, .trailing].contains(self)
        }

        var isBottom: Bool {
            [.bottomLeading, .bottom, .bottomTrailing].contains(self)
        }

        var isLeading: Bool {
            [.topLeading, .leading, .bottomLeading].contains(self)
        }

        var isHorizontalCenter: Bool {
            [.top, .center, .bottom].contains(self)
        }

        var isTrailing: Bool {
            [.topTrailing, .trailing, .bottomTrailing].contains(self)
        }
    }

    public enum AppearFrom {
        case top
        case bottom
        case left
        case right
    }

    public struct PopupParameters {
        var type: PopupType = .default

        var position: Position?

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

    var position: Position
    var appearFrom: AppearFrom?
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool

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

    /// Variable used to control what is animated and what is not
    @State var actualCurrentOffset: CGPoint = .zero

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGFloat = 0
    
    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if opaqueBackground {
            if position.isTop {
                return verticalPadding + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
            }
            if position.isVerticalCenter {
                return (screenHeight - sheetContentRect.height)/2 + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
            }
            if position.isBottom {
                return screenHeight - sheetContentRect.height - keyboardHeightHelper.keyboardHeight - verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0) - safeAreaInsets.top
            }
        }

        if position.isTop {
            return verticalPadding + (useSafeAreaInset ? 0 : -safeAreaInsets.top)
        }
        if position.isVerticalCenter {
            return (presenterContentRect.height - sheetContentRect.height)/2
        }
        if position.isBottom {
            return presenterContentRect.height - sheetContentRect.height + safeAreaInsets.bottom - verticalPadding + (useSafeAreaInset ? -safeAreaInsets.bottom : 0)
        }
        return 0
    }

    private var displayedOffsetX: CGFloat {
        if position.isLeading {
            return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
        }
        if position.isHorizontalCenter {
            return (screenSize.width - sheetContentRect.width)/2 - (useSafeAreaInset ? safeAreaInsets.leading : 0)
        }
        if position.isTrailing {
            return screenSize.width - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
        }
        return 0
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        let from: AppearFrom
        if let appearFrom = appearFrom {
            from = appearFrom
        } else if position.isLeading {
            from = .left
        } else if position.isTrailing {
            from = .right
        } else if position == .top {
            from = .top
        } else {
            from = .bottom
        }

        if sheetContentRect.isEmpty {
            return .zero
        }
        switch from {
        case .top:
            return CGPoint(x: displayedOffsetX, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottom:
            return CGPoint(x: displayedOffsetX, y: screenHeight)
        case .left:
            return CGPoint(x: -screenSize.width, y: displayedOffsetY)
        case .right:
            return CGPoint(x: screenSize.width, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        return shouldShowContent ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
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
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)
                //.onAnimationCompleted(for: currentOffset) {
                    //animationCompletedCallback() TEMP: need to fix
                //}
                .onChange(of: targetCurrentOffset) { newValue in
                    if !shouldShowContent, newValue == hiddenOffset { // don't animate initial positioning outside the screen
                        actualCurrentOffset = newValue
                    } else {
                        withAnimation(animation) {
                            actualCurrentOffset = newValue
                        }
                    }
                }
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
