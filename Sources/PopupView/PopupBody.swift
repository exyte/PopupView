//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

struct PopupBody<PopupContent: View>: View {

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

    @Binding var isDragging: Bool
    @Binding var timeToHide: Bool

    /// Trigger popup showing/hiding animations and...
    @Binding var shouldShowContent: Bool
    /// ... once hiding animation is finished remove popup from the memory using this flag
    @Binding var showContent: Bool

    // these are bindings to pass updates even through UIWindow
    @Binding var presenterContentRect: CGRect
    @Binding var sheetContentRect: CGRect

    var params: Popup.PopupParameters

    var popupBodyBuilder: () -> PopupContent

    /// Call dismiss callback with dismiss source
    var dismissCallback: (Popup.DismissSource)->()

    // MARK: - Private Properties

    @StateObject private var keyboardHeightHelper = KeyboardHeightHelper()

    /// Variables used to control what is animated and what is not
    @State private var actualCurrentOffset = CGPoint.pointFarAwayFromScreen
    @State private var actualScale = 1.0
#if os(iOS)
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
#endif

    // MARK: - Drag to dismiss

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGSize = .zero

    // MARK: - Drag to dismiss with scroll
#if os(iOS)
    @StateObject private var scrollViewDelegate = PopupScrollViewDelegate()
#endif

    /// Position when the scroll content offset became less than 0
    @State private var scrollViewOffset: CGSize = .zero

    /// Height of scrollView content that will be displayed on the screen
    @State private var scrollViewContentHeight = 0.0

    /// Track ScrollView's frame to check if it's ready
    @State private var scrollViewRect: CGRect = .zero

    // MARK: - Convenience getters

    var position: Popup.Position {
        params.position ?? params.type.defaultPosition
    }

    var useSafeAreaInset: Bool { params.type.useSafeAreaInset }
    var useKeyboardSafeArea: Bool { params.useKeyboardSafeArea }
    var verticalPadding: CGFloat { params.type.verticalPadding }
    var horizontalPadding: CGFloat { params.type.horizontalPadding }

    // MARK: - Position calculations

    var presenterRect: CGRect {
        params.displayMode == .overlay ? presenterContentRect : ScreenUtils.bounds
    }
    
    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if position.isTop {
            return presenterRect.minY - sheetContentRect.minY
            + verticalPadding
            + (useSafeAreaInset ? ScreenUtils.safeAreaInsets.top : 0)
        }
        if position.isVerticalCenter {
            return 0
        }
        if position.isBottom {
            // For .scroll type, keyboard avoidance is handled by constraining the
            // ScrollView's maxHeight in contentView(), so we don't shift the popup frame.
#if os(iOS)
            let keyboardOffset: CGFloat
            if case .scroll = params.type {
                keyboardOffset = 0
            } else {
                keyboardOffset = useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0
            }
#else
            let keyboardOffset: CGFloat = useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0
#endif
            return presenterRect.maxY - sheetContentRect.maxY
            - verticalPadding
            - (useSafeAreaInset ? ScreenUtils.safeAreaInsets.bottom : 0)
            - keyboardOffset
        }

        return 0
    }

    /// The offset when the popup is displayed
    private var displayedOffsetX: CGFloat {
        if position.isLeading {
            return presenterRect.minX - sheetContentRect.minX
            + horizontalPadding
            + (useSafeAreaInset ? ScreenUtils.safeAreaInsets.left : 0)
        }
        if position.isHorizontalCenter {
            return 0
        }
        if position.isTrailing {
            return presenterRect.maxX - sheetContentRect.maxX
            - horizontalPadding
            - (useSafeAreaInset ? ScreenUtils.safeAreaInsets.right : 0)
        }

        return 0
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        if sheetContentRect.isEmpty {
            return CGPoint.pointFarAwayFromScreen
        }

        // appearing animation
        if shouldShowContent {
            return hiddenOffset(calculatedAppearFrom)
        }
        // hiding animation
        return hiddenOffset(calculatedDisappearTo)
    }

    func hiddenOffset(_ appearAnimation: Popup.AppearAnimation) -> CGPoint {
        switch appearAnimation {
        case .topSlide:
            return CGPoint(x: displayedOffsetX, y: presenterRect.minY - sheetContentRect.maxY)
        case .bottomSlide:
            return CGPoint(x: displayedOffsetX, y: presenterRect.maxY - sheetContentRect.minY)
        case .leftSlide:
            return CGPoint(x: presenterRect.minX - sheetContentRect.maxX, y: displayedOffsetY)
        case .rightSlide:
            return CGPoint(x: presenterRect.maxX - sheetContentRect.minX, y: displayedOffsetY)
        case .centerScale, .none:
            return CGPoint(x: 0, y: 0)
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
        if shouldShowContent, calculatedAppearFrom == .centerScale {
            return 0
        }
        else if !shouldShowContent, calculatedDisappearTo == .centerScale {
            return 0
        }
        return 1
    }

    /// Passes the desired scale to actualScale allowing to animate selectively
    private var targetScale: CGFloat {
        shouldShowContent ? displayedScale : hiddenScale
    }

    // MARK: - Appear position direction calculations

    private var calculatedAppearFrom: Popup.AppearAnimation {
        let from: Popup.AppearAnimation
        if let appearFrom = params.appearFrom {
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

    private var calculatedDisappearTo: Popup.AppearAnimation {
        let to: Popup.AppearAnimation
        if let disappearTo = params.disappearTo {
            to = disappearTo
        } else if let appearFrom = params.appearFrom {
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

    // MARK: - Content Builders

    var body: some View {
        bodyWithGestures()
            .scaleEffect(actualScale)
            .offset(x: actualCurrentOffset.x, y: actualCurrentOffset.y)

            .onChange(of: shouldShowContent) {
                if actualCurrentOffset == CGPoint.pointFarAwayFromScreen { // don't animate initial positioning outside the screen
                    DispatchQueue.main.async {
                        actualCurrentOffset = hiddenOffset
                        actualScale = hiddenScale
                    }
                }

                DispatchQueue.main.async {
                    withAnimation(params.animation) {
                        changeParamsWithAnimation(shouldShowContent)
                    }
                }
            }

            .onChange(of: keyboardHeightHelper.keyboardHeight) {
                if shouldShowContent {
                    DispatchQueue.main.async {
                        withAnimation(params.animation) {
                            changeParamsWithAnimation(true)
                        }
                    }
                }
            }

            .onChange(of: sheetContentRect.size) {
#if os(iOS)
                // check if scrollView has already calculated its height, otherwise sheetContentRect is already non-zero but yet incorrect
                if case .scroll = params.type, scrollViewRect.height == 0 {
                    return
                }
#endif
                if shouldShowContent { // already displayed but the size has changed
                    actualCurrentOffset = targetCurrentOffset
                }
            }
#if os(iOS)
            .onOrientationChange(isLandscape: $isLandscape) {
                actualCurrentOffset = targetCurrentOffset
            }
#endif
    }

    func changeParamsWithAnimation(_ isDisplayAnimation: Bool) {
        self.actualCurrentOffset = isDisplayAnimation ? CGPointMake(displayedOffsetX, displayedOffsetY) : hiddenOffset
        self.actualScale = isDisplayAnimation ? displayedScale : hiddenScale
    }

    /// This is the builder for the sheet content
    @ViewBuilder
    func bodyWithGestures() -> some View {
        if showContent, presenterContentRect != .zero {
            addDragIfNeeded {
                addScrollIfNeeded {
                    popupBodyBuilder()
                }
            }
            .addTapIfNotTV(if: params.closeOnTap) {
                if params.dismissEnabled.wrappedValue {
                    dismissCallback(.tapInside)
                }
            }
        }
    }

    @ViewBuilder
    func addScrollIfNeeded<Content: View>(@ViewBuilder content: () -> Content) -> some View {
#if os(iOS)
        let dragGesture = DragGesture()
            .updating($dragState) { drag, state, _ in
                if !isDragging {
                    DispatchQueue.main.async {
                        isDragging = true
                    }
                }

                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        switch params.type {
        case .scroll(let headerView):
            VStack(spacing: 0) {
                AnyView(headerView)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(dragOffset())
                    .simultaneousGesture(dragGesture)

                ScrollView {
                    content()
                        .background(
                            ScrollViewResolver { scrollView in
                                configure(scrollView: scrollView)
                            }
                        )
                }
                .frame(maxHeight: max(0, scrollViewContentHeight - (useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)))
                .frameGetter($scrollViewRect)
                .offset(dragOffset())
            }
            .offset(CGSize(width: 0, height: scrollViewOffset.height))

        default:
            content()
        }
#else
        content()
#endif
    }

    @ViewBuilder
    func addDragIfNeeded<Content: View>(@ViewBuilder content: () -> Content) -> some View {
#if !os(tvOS)
        switch params.type {
#if os(iOS)
        case .scroll:
            content() // Drag to dismiss is handled inside
#endif
        default:
            let dragGesture = DragGesture()
                .updating($dragState) { drag, state, _ in
                    if !isDragging {
                        DispatchQueue.main.async {
                            isDragging = true
                        }
                    }
                    state = .dragging(translation: drag.translation)
                }
                .onEnded(onDragEnded)

            content()
                .applyIf(params.dragToDismiss) {
                    $0
                        .offset(dragOffset())
                        .simultaneousGesture(dragGesture)
                }
        }
#else
        content()
#endif
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
        case .centerScale, .none:
            return .zero
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        isDragging = false

        var referenceX = sheetContentRect.width / 3
        var referenceY = sheetContentRect.height / 3

        if let dragToDismissDistance = params.dragToDismissDistance {
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
        case .centerScale, .none:
            break
        }

        if timeToHide { // autohide timer was finished while the user was dragging
            timeToHide = false
            shouldDismiss = true
        }

        if params.dismissEnabled.wrappedValue, shouldDismiss {
            dismissCallback(.drag)
        } else {
            withAnimation {
                lastDragPosition = .zero
            }
        }
    }
#endif

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
            if params.dragToDismiss && -value >= referenceY {
                DispatchQueue.main.async {
                    dismissCallback(.drag)
                }
            } else {
                withAnimation {
                    scrollViewOffset = .zero
                }
            }
        }
    }

#endif
}

