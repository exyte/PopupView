//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

struct PopupBody<PopupContent: View>: View {

    // MARK: - Public Properties

    /// Trigger popup showing/hiding animations and...
    @Binding var shouldShowContent: Bool
    /// ... once hiding animation is finished remove popup from the memory using this flag
    @Binding var showContent: Bool

    // these are bindings to pass updates even through UIWindow
    @Binding var presenterContentRect: CGRect
    @Binding var sheetContentRect: CGRect

    @Binding var isDragging: Bool
    @Binding var timeToHide: Bool

    var params: Popup.BasePopupParameters

    var popupBodyBuilder: () -> PopupContent

    /// Call dismiss callback with dismiss source
    var dismissCallback: (Popup.DismissSource)->()

    // MARK: - Private Properties

    @StateObject private var keyboardHeightHelper = KeyboardHeightHelper()
    @StateObject private var dragToDismissManager = DragToDismissHelper()

    /// Variables used to control what is animated and what is not
    @State private var actualCurrentOffset = CGPoint.pointFarAwayFromScreen
    @State private var actualScale = 1.0
#if os(iOS)
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
#endif

    // MARK: - Convenience getters

    var typeParams: Popup.PopupTypeParameters? { params as? Popup.PopupTypeParameters }
    var scrollParams: Popup.ScrollPopupParameters? { params as? Popup.ScrollPopupParameters }

    var isScrollPopup: Bool { scrollParams != nil }

    var type: Popup.PopupType {
        typeParams?.type ?? .default
    }

    var position: Popup.Position {
        if let scrollParams { return scrollParams.position.toPopupPosition() }
        return typeParams?.position ?? type.defaultPosition
    }

    var useSafeAreaInset: Bool { type.useSafeAreaInset }
    var verticalPadding: CGFloat { type.verticalPadding }
    var horizontalPadding: CGFloat { type.horizontalPadding }

    // MARK: - Position calculations

    private var presenterRect: CGRect {
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
            return presenterRect.maxY - sheetContentRect.maxY
            - verticalPadding
            - (useSafeAreaInset ? ScreenUtils.safeAreaInsets.bottom : 0)
            - (params.useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)
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
        if let appearFrom = typeParams?.appearFrom {
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
        if let disappearTo = typeParams?.disappearTo {
            to = disappearTo
        } else if let appearFrom = typeParams?.appearFrom {
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
            .background {
                if params.displayMode == .window {
                    PopupHitRegion() // apply here, because offset doesn't actually change popup's position, effectively breaking expected behaviour
                }
            }
            .scaleEffect(actualScale)
            .offset(x: actualCurrentOffset.x, y: actualCurrentOffset.y)

            .onChange(of: shouldShowContent) {
                // perform initial off screen positioning without animation
                if actualCurrentOffset == CGPoint.pointFarAwayFromScreen {
                    actualCurrentOffset = hiddenOffset
                    actualScale = hiddenScale
                }

                changeParamsWithAnimation(shouldShowContent)
            }

            .onChange(of: keyboardHeightHelper.keyboardHeight) {
                if shouldShowContent {
                    changeParamsWithAnimation(true)
                }
            }

            .onChange(of: sheetContentRect.size) {
                if shouldShowContent { // already displayed but the size has changed
                    actualCurrentOffset = targetCurrentOffset
                }
            }

            .task {
                dragToDismissManager.configure(
                    sheetContentRect: $sheetContentRect,
                    isDragging: $isDragging,
                    timeToHide: $timeToHide,
                    params: params,
                    appearFrom: calculatedAppearFrom,
                    shouldDismiss: { dismissCallback(.drag) }
                )
            }

#if os(iOS)
            .onOrientationChange(isLandscape: $isLandscape) {
                actualCurrentOffset = targetCurrentOffset
            }
#endif
    }

    func changeParamsWithAnimation(_ isDisplayAnimation: Bool) {
        withAnimation(params.animation) {
            self.actualCurrentOffset = isDisplayAnimation ? CGPointMake(displayedOffsetX, displayedOffsetY) : hiddenOffset
            self.actualScale = isDisplayAnimation ? displayedScale : hiddenScale
        }
    }

    /// This is the builder for the sheet content
    @ViewBuilder
    func bodyWithGestures() -> some View {
        if showContent, presenterContentRect != .zero {
            popupBodyBuilder()
                .applyIfNotNil(scrollParams) { view, params in
                    view.modifier(ScrollPopupModifier(
                        dragToDismissManager: dragToDismissManager,
                        sheetContentRect: $sheetContentRect,
                        scrollParams: params,
                        shouldDismiss: { dismissCallback(.drag) }
                    ))
                }
                // scroll popup will attach this gesture on its own
                .applyIfNotTV(if: params.dragToDismiss && !isScrollPopup) { view in
                    view.simultaneousGesture(dragToDismissManager.dragGesture)
                        .offset(dragToDismissManager.dragTranslation)
                }
                .addTapIfNotTV(if: params.closeOnTap) {
                    if params.dismissEnabled.wrappedValue {
                        dismissCallback(.tapInside)
                    }
                }
        }
    }
}
