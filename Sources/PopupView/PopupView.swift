//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
#if os(iOS)
@_spi(Advanced) import SwiftUIIntrospect
#endif

public struct Popup<PopupContent: View>: ViewModifier {

    init(params: Popup<PopupContent>.PopupParameters,
         view: @escaping () -> PopupContent,
         shouldShowContent: Binding<Bool>,
         showContent: Bool,
         isDragging: Binding<Bool>,
         timeToHide: Binding<Bool>,
         positionIsCalculatedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.type = params.type
        self.displayMode = params.displayMode
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
        self.dismissEnabled = params.dismissEnabled
        self.closeOnTap = params.closeOnTap

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self._isDragging = isDragging
        self._timeToHide = timeToHide
        self.positionIsCalculatedCallback = positionIsCalculatedCallback
        self.dismissCallback = dismissCallback
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
    var displayMode: DisplayMode
    var position: Position
    var appearFrom: AppearAnimation?
    var disappearTo: AppearAnimation?
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool
    var useKeyboardSafeArea: Bool

    var animation: Animation

    /// Becomes true when `dismissibleIn` times finishes
    /// Makes no sense if `dismissibleIn` is nil
    var dismissEnabled: Binding<Bool>

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// Minimum distance to drag to dismiss
    var dragToDismissDistance: CGFloat?

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Binding<Bool>

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// called when all the offsets are calculated, so everything is ready for animation
    var positionIsCalculatedCallback: () -> ()

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
#if os(iOS)
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
#endif
    // MARK: - Drag to dismiss

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGSize = .zero

    @Binding var isDragging: Bool

    @Binding var timeToHide: Bool

    // MARK: - Drag to dismiss with scroll
#if os(iOS)
    /// UIScrollView delegate, needed for calling didEndDragging
    @StateObject private var scrollViewDelegate = PopupScrollViewDelegate()
#endif

    /// Position when the scroll content offset became less than 0
    @State private var scrollViewOffset: CGSize = .zero

    /// Height of scrollView content that will be displayed on the screen
    @State private var scrollViewContentHeight = 0.0

    /// Track ScrollView's frame to check if it's ready
    @State private var scrollViewRect: CGRect = .zero

    // MARK: - Position calculations

    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if displayMode != .overlay {
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
        if displayMode != .overlay {
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
        if shouldShowContent.wrappedValue {
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
        case .centerScale, .none:
            return CGPoint(x: displayedOffsetX, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        shouldShowContent.wrappedValue ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
    }

    // MARK: - Scale calculations

    /// The scale when the popup is displayed
    private var displayedScale: CGFloat {
        1
    }

    /// The scale when the popup is hidden
    private var hiddenScale: CGFloat {
        if shouldShowContent.wrappedValue, calculatedAppearFrom == .centerScale {
            return 0
        }
        else if !shouldShowContent.wrappedValue, calculatedDisappearTo == .centerScale {
            return 0
        }
        return 1
    }

    /// Passes the desired scale to actualScale allowing to animate selectively
    private var targetScale: CGFloat {
        shouldShowContent.wrappedValue ? displayedScale : hiddenScale
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
                .frameGetter($scrollViewRect)
            }
            .introspect(.scrollView, on: .iOS(.v15...)) { scrollView in
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
                            if dismissEnabled.wrappedValue {
                                dismissCallback(.tapInside)
                            }
                        }
                        .scaleEffect(actualScale) // scale is here to avoid it messing with frameGetter for sheetContentRect
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)

                .onChange(of: shouldShowContent.wrappedValue) { newValue in
                    if actualCurrentOffset == CGPoint.pointFarAwayFromScreen { // don't animate initial positioning outside the screen
                        DispatchQueue.main.async {
                            actualCurrentOffset = hiddenOffset
                            actualScale = hiddenScale
                        }
                    }

                    DispatchQueue.main.async {
                        withAnimation(animation) {
                            changeParamsWithAnimation(newValue)
                        }
                    }
                }

                .onChange(of: keyboardHeightHelper.keyboardHeight) { _ in
                    if shouldShowContent.wrappedValue {
                        DispatchQueue.main.async {
                            withAnimation(animation) {
                                changeParamsWithAnimation(true)
                            }
                        }
                    }
                }

                .onChange(of: sheetContentRect.size) { sheetContentRect in
                    #if os(iOS)
                    // check if scrollView has already calculated its height, otherwise sheetContentRect is already non-zero but yet incorrect
                    if case .scroll(_) = type, scrollViewRect.height == 0 {
                        return
                    }
                    #endif
                    positionIsCalculatedCallback()
                    if shouldShowContent.wrappedValue { // already displayed but the size has changed
                        actualCurrentOffset = targetCurrentOffset
                    }
                }
#if os(iOS)
                .onOrientationChange(isLandscape: $isLandscape) {
                    actualCurrentOffset = targetCurrentOffset
                }
#endif
            }
        } else { // ios 16
            ZStack {
                VStack {
                    contentView()
                        .addTapIfNotTV(if: closeOnTap) {
                            if dismissEnabled.wrappedValue {
                                dismissCallback(.tapInside)
                            }
                        }
                        .scaleEffect(actualScale) // scale is here to avoid it messing with frameGetter for sheetContentRect
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)

                .onChange(of: targetCurrentOffset) { newValue in
                    if !shouldShowContent.wrappedValue, newValue == hiddenOffset { // don't animate initial positioning outside the screen
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
                    if !shouldShowContent.wrappedValue, newValue == hiddenScale { // don't animate initial positioning outside the screen
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
#if os(iOS)
                .onOrientationChange(isLandscape: $isLandscape) {
                    actualCurrentOffset = targetCurrentOffset
                }
#endif
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
                if !isDragging {
                    DispatchQueue.main.async {
                        isDragging = true
                    }
                }
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet()
            .applyIf(dragToDismiss) {
                $0
                    .offset(dragOffset())
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
        case .centerScale, .none:
            return .zero
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        isDragging = false

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
        case .centerScale, .none:
            break
        }

        if timeToHide { // autohide timer was finished while the user was dragging
            timeToHide = false
            shouldDismiss = true
        }

        if dismissEnabled.wrappedValue, shouldDismiss {
            dismissCallback(.drag)
        } else {
            withAnimation {
                lastDragPosition = .zero
            }
        }
    }
#endif
}
