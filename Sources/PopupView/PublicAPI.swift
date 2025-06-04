//
//  PublicAPI.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.03.2025.
//

import SwiftUI

public enum DismissSource {
    case binding // set isPresented to false ot item to nil
    case tapInside
    case tapOutside
    case drag
    case autohide
}

extension Popup {

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

    public enum DisplayMode {
        case overlay // place the popup above the content in a ZStack
        case sheet // using .fullscreenSheet
        case window // using UIWindow
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
        case none
    }

    public struct PopupParameters {
        var type: PopupType = .default
        var displayMode: DisplayMode = .window
        var position: Position?

        var appearFrom: AppearAnimation?
        var disappearTo: AppearAnimation?

        var animation: Animation = .easeOut(duration: 0.3)

        /// If nil - never hides on its own
        var autohideIn: Double?

        /// Only allow dismiss by any means after this time passes
        var dismissibleIn: Double?

        /// Becomes true when `dismissibleIn` times finishes
        /// Makes no sense if `dismissibleIn` is nil
        var dismissEnabled: Binding<Bool> = .constant(true)

        /// Should allow dismiss by dragging - default is `true`
        var dragToDismiss: Bool = true

        /// Minimum distance to drag to dismiss
        var dragToDismissDistance: CGFloat?

        /// Should close on tap - default is `true`
        var closeOnTap: Bool = true

        /// Should close on tap outside - default is `false`
        var closeOnTapOutside: Bool = false

        /// Should allow taps to pass "through" the popup's background down to views "below" it.
        /// .sheet popup is always allowTapThroughBG = false
        var allowTapThroughBG: Bool = true

        /// Background color for outside area
        var backgroundColor: Color = .clear

        /// Custom background view for outside area
        var backgroundView: AnyView?

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

        public func displayMode(_ displayMode: DisplayMode) -> PopupParameters {
            var params = self
            params.displayMode = displayMode
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

        public func dismissibleIn(_ dismissibleIn: Double?, _ dismissEnabled: Binding<Bool>?) -> PopupParameters {
            var params = self
            params.dismissibleIn = dismissibleIn
            if let dismissEnabled = dismissEnabled {
                params.dismissEnabled = dismissEnabled
            }
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

        public func allowTapThroughBG(_ allowTapThroughBG: Bool) -> PopupParameters {
            var params = self
            params.allowTapThroughBG = allowTapThroughBG
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

        @available(*, deprecated, message: "use displayMode instead")
        public func isOpaque(_ isOpaque: Bool) -> PopupParameters {
            var params = self
            params.displayMode = isOpaque ? .sheet : .overlay
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
}
