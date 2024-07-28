//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
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
         popupPresented: Bool,
         shouldShowContent: Bool,
         showContent: Bool,
         positionIsCalculatedCallback: @escaping () -> (),
         animationCompletedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.type = params.type
        self.position = params.position ?? params.type.defaultPosition
        self.appearFrom = params.appearFrom
        self.disappearTo = params.disappearTo
        self.verticalPadding = params.type.verticalPadding
        self.horizontalPadding = params.type.horizontalPadding
        self.useSafeAreaInset = params.type.useSafeAreaInset
        self.useKeyboardSafeArea = params.useKeyboardSafeArea
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.dragToDismissDistance = params.dragToDismissDistance
        self.closeOnTap = params.closeOnTap
        self.isOpaque = params.isOpaque

        self.view = view

        self.popupPresented = popupPresented
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

    public enum AppearAnimation {
        case topSlide
        case bottomSlide
        case leftSlide
        case rightSlide
        case centerScale
    }

    public struct PopupParameters {
        var type: PopupType = .default

        var position: Position?

        var appearFrom: AppearAnimation?
        var disappearTo: AppearAnimation?

        var animation: Animation = .easeOut(duration: 0.3)

        /// If nil - never hides on its own
        var autohideIn: Double?

        /// Should allow dismiss by dragging - default is `true`
        var dragToDismiss: Bool = true
        
        /// Minimum distance to drag to dismiss
        var dragToDismissDistance: CGFloat?

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

        public func appearFrom(_ appearFrom: AppearAnimation) -> PopupParameters {
            var params = self
            params.appearFrom = appearFrom
            return params
        }

        public func disappearTo(_ disappearTo: AppearAnimation) -> PopupParameters {
            var params = self
            params.disappearTo = disappearTo
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
        
        /// Minimum distance to drag to dismiss
        public func dragToDismissDistance(_ dragToDismissDistance: CGFloat) -> PopupParameters {
            var params = self
            params.dragToDismissDistance = dragToDismissDistance
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
    var appearFrom: AppearAnimation?
    var disappearTo: AppearAnimation?
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool
    var useKeyboardSafeArea: Bool

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// Minimum distance to drag to dismiss
    var dragToDismissDistance: CGFloat?
    
    /// If opaque - taps do not pass through popup's background color
    var isOpaque: Bool

    /// Variable showing changes in isPresented/item, used here to determine direction of animation (showing or hiding)
    var popupPresented: Bool

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

    /// Variables used to control what is animated and what is not
    @State var actualCurrentOffset = CGPoint.pointFarAwayFromScreen
    @State var actualScale = 1.0

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

    /// The offset when the popup is displayed
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

        // appearing animation
        if popupPresented {
            return hiddenOffset(calculatedAppearFrom)
        }
        // hiding animation
        else {
            return hiddenOffset(calculatedDisappearTo)
        }
    }

    func hiddenOffset(_ appearAnimation: AppearAnimation) -> CGPoint {
        switch appearAnimation {
        case .topSlide:
            return CGPoint(x: displayedOffsetX, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottomSlide:
            return CGPoint(x: displayedOffsetX, y: screenHeight)
        case .leftSlide:
            return CGPoint(x: -screenWidth, y: displayedOffsetY)
        case .rightSlide:
            return CGPoint(x: screenWidth, y: displayedOffsetY)
        case .centerScale:
            return CGPoint(x: displayedOffsetX, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        shouldShowContent ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
    }

    // MARK: - Scale calculations

    /// The scale when the popup is displayed
    private var displayedScale: CGFloat {
        1
    }

    /// The scale when the popup is hidden
    private var hiddenScale: CGFloat {
        if popupPresented, calculatedAppearFrom == .centerScale {
            return 0
        }
        else if !popupPresented, calculatedDisappearTo == .centerScale {
            return 0
        }
        return 1
    }

    /// Passes the desired scale to actualScale allowing to animate selectively
    private var targetScale: CGFloat {
        shouldShowContent ? displayedScale : hiddenScale
    }

    // MARK: - Appear position direction calculations

    private var calculatedAppearFrom: AppearAnimation {
        let from: AppearAnimation
        if let appearFrom = appearFrom {
            from = appearFrom
        } else if position.isLeading {
            from = .leftSlide
        } else if position.isTrailing {
            from = .rightSlide
        } else if position == .top {
            from = .topSlide
        } else {
            from = .bottomSlide
        }
        return from
    }

    private var calculatedDisappearTo: AppearAnimation {
        let to: AppearAnimation
        if let disappearTo = disappearTo {
            to = disappearTo
        } else if let appearFrom = appearFrom {
            to = appearFrom
        } else if position.isLeading {
            to = .leftSlide
        } else if position.isTrailing {
            to = .rightSlide
        } else if position == .top {
            to = .topSlide
        } else {
            to = .bottomSlide
        }
        return to
    }

#if os(iOS)
    private func configure(scrollView: UIScrollView) {
        scrollViewDelegate.scrollView = scrollView
        scrollViewDelegate.addGestureIfNeeded()

        DispatchQueue.main.async {
            scrollViewContentHeight = scrollView.contentSize.height
        }

        scrollViewDelegate.didReachTop = { value in
            scrollViewOffset = CGSize(width: 0, height: -value)
        }

        let referenceY = sheetContentRect.height / 3
        scrollViewDelegate.scrollEnded = { value in
            if -value >= referenceY {
                dismissCallback(.drag)
            } else {
                withAnimation {
                    scrollViewOffset = .zero
                }
            }
        }

        scrollView.delegate = scrollViewDelegate
    }

#endif

    var screenSize: CGSize {
#if os(iOS)
        return UIApplication.shared.connectedScenes
            .compactMap({ scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }).first?.frame.size ?? .zero
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
                        sheetWithDragGesture()
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
                    .fixedSize(horizontal: false, vertical: true)
                ScrollView {
                    view()
                }
                // no heigher than its contents
                .frame(maxHeight: scrollViewContentHeight)
            }
            .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18)) { scrollView in
                configure(scrollView: scrollView)
            }
            .offset(CGSize(width: 0, height: scrollViewOffset.height))

        default:
            view()
        }
#else
        view()
#endif
    }

#if swift(>=5.9)
    /// This is the builder for the sheet content
    @ViewBuilder
    func sheet() -> some View {
        if #available(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0, *) {
            ZStack {
                VStack {
                    contentView()
                        .addTapIfNotTV(if: closeOnTap) {
                            dismissCallback(.tapInside)
                        }
                        .scaleEffect(actualScale) // scale is here to avoid it messing with frameGetter for sheetContentRect
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)

                .onChange(of: shouldShowContent) { newValue in
                    if actualCurrentOffset == CGPoint.pointFarAwayFromScreen { // don't animate initial positioning outside the screen
                        DispatchQueue.main.async {
                            actualCurrentOffset = hiddenOffset
                            actualScale = hiddenScale
                        }
                    }

                    DispatchQueue.main.async {
                        withAnimation(animation) {
                            changeParamsWithAnimation(newValue)
                        } completion: {
                            animationCompletedCallback()
                        }
                    }
                }

                .onChange(of: keyboardHeightHelper.keyboardHeight) { _ in
                    if shouldShowContent {
                        DispatchQueue.main.async {
                            withAnimation(animation) {
                                changeParamsWithAnimation(true)
                            }
                        }
                    }
                }

                .onChange(of: sheetContentRect.size) { sheetContentRect in
                    positionIsCalculatedCallback()
                }
            }
        } else { // ios 16
            ZStack {
                VStack {
                    contentView()
                        .addTapIfNotTV(if: closeOnTap) {
                            dismissCallback(.tapInside)
                        }
                        .scaleEffect(actualScale) // scale is here to avoid it messing with frameGetter for sheetContentRect
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)

                .onChange(of: targetCurrentOffset) { newValue in
                    if !shouldShowContent, newValue == hiddenOffset { // don't animate initial positioning outside the screen
                        actualCurrentOffset = newValue
                        actualScale = targetScale
                    } else {
                        withAnimation(animation) {
                            actualCurrentOffset = newValue
                            actualScale = targetScale
                        }
                    }
                }

                .onChange(of: targetScale) { newValue in
                    if !shouldShowContent, newValue == hiddenScale { // don't animate initial positioning outside the screen
                        actualCurrentOffset = targetCurrentOffset
                        actualScale = newValue
                    } else {
                        withAnimation(animation) {
                            actualCurrentOffset = targetCurrentOffset
                            actualScale = newValue
                        }
                    }
                }

                .onChange(of: sheetContentRect.size) { sheetContentRect in
                    positionIsCalculatedCallback()
                }
            }
        }
    }
#else
#error("This project requires Swift 5.9 or newer. Please update your Xcode to compile this project.")
#endif

    func sheetWithDragGesture() -> some View {
#if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet()
            .applyIf(dragToDismiss) {
                $0.offset(dragOffset())
                    .simultaneousGesture(drag)
            }
#else
        return sheet()
#endif
    }

    func changeParamsWithAnimation(_ isDisplayAnimation: Bool) {
        self.actualCurrentOffset = isDisplayAnimation ? CGPointMake(displayedOffsetX, displayedOffsetY) : hiddenOffset
        self.actualScale = isDisplayAnimation ? displayedScale : hiddenScale
    }

#if !os(tvOS)
    func dragOffset() -> CGSize {
        if dragState.translation == .zero {
            return lastDragPosition
        }

        switch calculatedAppearFrom {
        case .topSlide:
            if dragState.translation.height < 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .bottomSlide:
            if dragState.translation.height > 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .leftSlide:
            if dragState.translation.width < 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .rightSlide:
            if dragState.translation.width > 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .centerScale:
            return .zero
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        var referenceX = sheetContentRect.width / 3
        var referenceY = sheetContentRect.height / 3
        
        if let dragToDismissDistance = dragToDismissDistance {
            referenceX = dragToDismissDistance
            referenceY = dragToDismissDistance
        }
        
        var shouldDismiss = false
        switch calculatedAppearFrom {
        case .topSlide:
            if drag.translation.height < 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height < -referenceY {
                shouldDismiss = true
            }
        case .bottomSlide:
            if drag.translation.height > 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height > referenceY {
                shouldDismiss = true
            }
        case .leftSlide:
            if drag.translation.width < 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width < -referenceX {
                shouldDismiss = true
            }
        case .rightSlide:
            if drag.translation.width > 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width > referenceX {
                shouldDismiss = true
            }
        case .centerScale:
            break
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
