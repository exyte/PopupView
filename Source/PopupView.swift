//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import Combine
#if os(iOS)
import SwiftUIIntrospect
#endif

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
         shouldShowContent: Bool,
         showContent: Bool,
         positionIsCalculatedCallback: @escaping () -> (),
         animationCompletedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.type = params.type
        self.position = params.position ?? params.type.defaultPosition
        self.appearFrom = params.appearFrom
        self.verticalPadding = params.type.verticalPadding
        self.horizontalPadding = params.type.horizontalPadding
        self.useSafeAreaInset = params.type.useSafeAreaInset
        self.useKeyboardSafeArea = params.useKeyboardSafeArea
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.closeOnTap = params.closeOnTap
        self.isOpaque = params.isOpaque

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self.positionIsCalculatedCallback = positionIsCalculatedCallback
        self.animationCompletedCallback = animationCompletedCallback
        self.dismissCallback = dismissCallback
    }

    public enum PopupType {

        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, horizontalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)
#if os(iOS)
        case scroll(headerView: AnyView)
#endif

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

        /// Should allow dismiss by dragging - default is `true`
        var dragToDismiss: Bool = true

        /// Should close on tap - default is `true`
        var closeOnTap: Bool = true

        /// Should close on tap outside - default is `false`
        var closeOnTapOutside: Bool = false

        /// Background color for outside area
        var backgroundColor: Color = .clear

        /// Custom background view for outside area
        var backgroundView: AnyView?

        /// If true - taps do not pass through popup's background and the popup is displayed on top of navbar
        var isOpaque: Bool = false

        /// move up for keyboardHeight when it is displayed
        var useKeyboardSafeArea: Bool = false

        /// called when when dismiss animation starts
        var willDismissCallback: (DismissSource) -> () = {_ in}

        /// called when when dismiss animation ends
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

        /// Should allow dismiss by dragging - default is `true`
        public func dragToDismiss(_ dragToDismiss: Bool) -> PopupParameters {
            var params = self
            params.dragToDismiss = dragToDismiss
            return params
        }

        /// Should close on tap - default is `true`
        public func closeOnTap(_ closeOnTap: Bool) -> PopupParameters {
            var params = self
            params.closeOnTap = closeOnTap
            return params
        }

        /// Should close on tap outside - default is `false`
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

        public func useKeyboardSafeArea(_ useKeyboardSafeArea: Bool) -> PopupParameters {
            var params = self
            params.useKeyboardSafeArea = useKeyboardSafeArea
            return params
        }

        // MARK: - dismiss callbacks

        public func willDismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.willDismissCallback = dismissCallback
            return params
        }

        public func willDismissCallback(_ dismissCallback: @escaping () -> ()) -> PopupParameters {
            var params = self
            params.willDismissCallback = { _ in
                dismissCallback()
            }
            return params
        }

        @available(*, deprecated, renamed: "dismissCallback")
        public func dismissSourceCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = dismissCallback
            return params
        }

        public func dismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
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
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool
    var useKeyboardSafeArea: Bool

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// If opaque - taps do not pass through popup's background color
    var isOpaque: Bool

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Bool

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// called when all the offsets are calculated, so everything is ready for animation
    var positionIsCalculatedCallback: () -> ()

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
    @State var actualCurrentOffset = CGPoint.pointFarAwayFromScreen

    // MARK: - Drag to dismiss

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGSize = .zero

    // MARK: - Drag to dismiss with scroll
#if os(iOS)
    /// UIScrollView delegate, needed for calling didEndDragging
    @StateObject private var scrollViewDelegate = PopupScrollViewDelegate()
#endif

    /// Position when the scroll content offset became less than 0
    @State private var scrollViewOffset: CGSize = .zero

    /// Height of scrollView content that will be displayed on the screen
    @State var scrollViewContentHeight = 0.0

    // MARK: - Position calculations

    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if isOpaque {
            if position.isTop {
                return verticalPadding + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
            }
            if position.isVerticalCenter {
                return (screenHeight - sheetContentRect.height)/2 - safeAreaInsets.top
            }
            if position.isBottom {
                return screenHeight - sheetContentRect.height
                - (useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)
                - verticalPadding
                - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
                - safeAreaInsets.top
            }
        }

        if position.isTop {
            return verticalPadding + (useSafeAreaInset ? 0 : -safeAreaInsets.top)
        }
        if position.isVerticalCenter {
            return (presenterContentRect.height - sheetContentRect.height)/2
        }
        if position.isBottom {
            return presenterContentRect.height
            - sheetContentRect.height
            - (useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)
            - verticalPadding
            + safeAreaInsets.bottom
            - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
        }
        return 0
    }

    private var displayedOffsetX: CGFloat {
        if isOpaque {
            if position.isLeading {
                return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
            }
            if position.isHorizontalCenter {
                return (screenWidth - sheetContentRect.width)/2 - safeAreaInsets.leading
            }
            if position.isTrailing {
                return screenWidth - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
            }
        }

        if position.isLeading {
            return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
        }
        if position.isHorizontalCenter {
            return (presenterContentRect.width - sheetContentRect.width)/2
        }
        if position.isTrailing {
            return presenterContentRect.width - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
        }
        return 0
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        if sheetContentRect.isEmpty {
            return CGPoint.pointFarAwayFromScreen
        }

        switch calculatedAppearFrom {
        case .top:
            return CGPoint(x: displayedOffsetX, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottom:
            return CGPoint(x: displayedOffsetX, y: screenHeight)
        case .left:
            return CGPoint(x: -screenWidth, y: displayedOffsetY)
        case .right:
            return CGPoint(x: screenWidth, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        shouldShowContent ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
    }

    private var calculatedAppearFrom: AppearFrom {
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
        return from
    }

#if os(iOS)
    private func configure(scrollView: UIScrollView) {
        scrollView.delegate = scrollViewDelegate

        scrollViewDelegate.scrollView = scrollView
        scrollViewDelegate.addGestureIfNeeded()
        let referenceY = sheetContentRect.height / 3

        scrollViewDelegate.didReachTop = { value in
            scrollViewOffset = CGSize(width: 0, height: -value)
        }

        scrollViewDelegate.scrollEnded = { value in
            if -value >= referenceY {
                dismissCallback(.drag)
            } else {
                withAnimation {
                    scrollViewOffset = .zero
                }
            }
        }
    }

#endif

    var screenSize: CGSize {
#if os(iOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#else
        return CGSize(width: presenterContentRect.size.width, height: presenterContentRect.size.height - presenterContentRect.minY)
#endif
    }

    private var screenWidth: CGFloat {
        screenSize.width
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

    @ViewBuilder
    private func contentView() -> some View {
#if os(iOS)
        switch type {
        case .scroll(let headerView):
            VStack(spacing: 0) {
                headerView
                    .calculateHeight(height: $scrollViewContentHeight)
                ScrollView {
                    view()
                        .calculateHeight(height: $scrollViewContentHeight)
                }
                /// Max height of scrollView content that will be displayed on the screen
                .frame(height: scrollViewContentHeight)
                .introspect(.scrollView, on: .iOS(.v15, .v16, .v17)) { scrollView in
                    configure(scrollView: scrollView)
                }
                .layoutPriority(1)
            }
            .offset(CGSize(width: 0, height: scrollViewOffset.height))

        default:
            view()
        }
#else
        view()
#endif
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {
        let sheet = ZStack {
            contentView()
                .addTapIfNotTV(if: closeOnTap) {
                    dismissCallback(.tapInside)
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)
                .valueChanged(value: targetCurrentOffset) { newValue in
                    if !shouldShowContent, newValue == hiddenOffset { // don't animate initial positioning outside the screen
                        actualCurrentOffset = newValue
                    } else {
                        if #available(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0, *) {
#if swift(>=5.9)
                            withAnimation(animation) {
                                actualCurrentOffset = newValue
                            } completion: {
                                animationCompletedCallback()
                            }
#else
                            withAnimation(animation) {
                                actualCurrentOffset = newValue
                            }
#endif
                        } else {
                            withAnimation(animation) {
                                actualCurrentOffset = newValue
                            }
                        }
                    }
                }
                .valueChanged(value: sheetContentRect.size) { sheetContentRect in
                    positionIsCalculatedCallback()
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
                $0.offset(dragOffset())
                    .simultaneousGesture(drag)
            }
#else
        return sheet
#endif
    }

#if !os(tvOS)
    func dragOffset() -> CGSize {
        if dragState.translation == .zero {
            return lastDragPosition
        }

        switch calculatedAppearFrom {
        case .top:
            if dragState.translation.height < 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .bottom:
            if dragState.translation.height > 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .left:
            if dragState.translation.width < 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .right:
            if dragState.translation.width > 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let referenceX = sheetContentRect.width / 3
        let referenceY = sheetContentRect.height / 3

        var shouldDismiss = false
        switch calculatedAppearFrom {
        case .top:
            if drag.translation.height < 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height < -referenceY {
                shouldDismiss = true
            }
        case .bottom:
            if drag.translation.height > 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height > referenceY {
                shouldDismiss = true
            }
        case .left:
            if drag.translation.width < 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width < -referenceX {
                shouldDismiss = true
            }
        case .right:
            if drag.translation.width > 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width > referenceX {
                shouldDismiss = true
            }
        }

        if shouldDismiss {
            dismissCallback(.drag)
        } else {
            withAnimation {
                lastDragPosition = .zero
            }
        }
    }
#endif
}
