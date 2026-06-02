//
//  PublicAPI.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.03.2025.
//

import SwiftUI

public class Popup {

    public enum PopupType {
        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, horizontalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)

        public var isToast: Bool {
            if case .toast = self { return true }
            return false
        }

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

    public enum DisplayMode: Identifiable {
        case overlay // place the popup above the content in an .overlay
        case sheet // using .fullscreenSheet
        case window // using UIWindow

        public var id: Self { self }
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

    public enum DismissSource {
        case binding // set isPresented to false ot item to nil
        case tapInside
        case tapOutside
        case drag
        case autohide
        case exitCommand // TV Remove/ESC on Mac
    }

    public protocol PopupParameters {}

    public class BasePopupParameters: PopupParameters {
        var displayMode: DisplayMode = .window

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
        /// NOTE: any gesture or control element you add to popup's body will override tap to close. in this case please close the popup manually if you need it to
        var closeOnTap: Bool = true

        /// Should close on tap outside - default is `false`
        var closeOnTapOutside: Bool = false

        /// Should allow taps to pass "through" the popup's background down to views "below" it.
        /// .sheet popup is always allowTapThroughBG = false
        var allowTapThroughBG: Bool = false

        /// Background color for outside area
        var backgroundColor: Color? = nil

        /// Custom background view for outside area
        var backgroundView: AnyView?

        /// move up for keyboardHeight when it is displayed
        var useKeyboardSafeArea: Bool = false

        /// called when when dismiss animation starts
        var willDismissCallback: (DismissSource) -> () = {_ in}

        /// called when when dismiss animation ends
        var dismissCallback: (DismissSource) -> () = {_ in}

        public func displayMode(_ displayMode: DisplayMode) -> Self {
            self.displayMode = displayMode
            return self
        }

        public func animation(_ animation: Animation) -> Self {
            self.animation = animation
            return self
        }

        public func autohideIn(_ autohideIn: Double?) -> Self {
            self.autohideIn = autohideIn
            return self
        }

        public func dismissibleIn(_ dismissibleIn: Double?, _ dismissEnabled: Binding<Bool>?) -> Self {
            self.dismissibleIn = dismissibleIn
            if let dismissEnabled = dismissEnabled {
                self.dismissEnabled = dismissEnabled
            }
            return self
        }

        /// Should allow dismiss by dragging - default is `true`
        public func dragToDismiss(_ dragToDismiss: Bool) -> Self {
            self.dragToDismiss = dragToDismiss
            return self
        }

        /// Minimum distance to drag to dismiss
        public func dragToDismissDistance(_ dragToDismissDistance: CGFloat) -> Self {
            self.dragToDismissDistance = dragToDismissDistance
            return self
        }

        /// Should close on tap - default is `true`
        /// NOTE: any gesture or control element you add to popup's body will override tap to close. in this case please close the popup manually if you need it to
        public func closeOnTap(_ closeOnTap: Bool) -> Self {
            self.closeOnTap = closeOnTap
            return self
        }

        /// Should close on tap outside - default is `false`
        public func closeOnTapOutside(_ closeOnTapOutside: Bool) -> Self {
            self.closeOnTapOutside = closeOnTapOutside
            return self
        }

        public func allowTapThroughBG(_ allowTapThroughBG: Bool) -> Self {
            self.allowTapThroughBG = allowTapThroughBG
            return self
        }

        public func backgroundColor(_ backgroundColor: Color) -> Self {
            self.backgroundColor = backgroundColor
            return self
        }

        public func backgroundView<BackgroundView: View>(_ backgroundView: ()->(BackgroundView)) -> Self {
            self.backgroundView = AnyView(backgroundView())
            return self
        }

        @available(*, deprecated, message: "use displayMode instead")
        public func isOpaque(_ isOpaque: Bool) -> Self {
            self.displayMode = isOpaque ? .sheet : .overlay
            return self
        }

        public func useKeyboardSafeArea(_ useKeyboardSafeArea: Bool) -> Self {
            self.useKeyboardSafeArea = useKeyboardSafeArea
            return self
        }

        // MARK: - dismiss callbacks

        public func willDismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> Self {
            self.willDismissCallback = dismissCallback
            return self
        }

        public func willDismissCallback(_ dismissCallback: @escaping () -> ()) -> Self {
            self.willDismissCallback = { _ in
                dismissCallback()
            }
            return self
        }

        @available(*, deprecated, renamed: "dismissCallback")
        public func dismissSourceCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> Self {
            self.dismissCallback = dismissCallback
            return self
        }

        public func dismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> Self {
            self.dismissCallback = dismissCallback
            return self
        }

        public func dismissCallback(_ dismissCallback: @escaping () -> ()) -> Self {
            self.dismissCallback = { _ in
                dismissCallback()
            }
            return self
        }
    }

    public class PopupTypeParameters: BasePopupParameters {
        var type: PopupType = .default
        var position: Position?

        var appearFrom: AppearAnimation?
        var disappearTo: AppearAnimation?

        public func type(_ type: PopupType) -> Self {
            self.type = type
            return self
        }

        public func position(_ position: Position) -> Self {
            self.position = position
            return self
        }

        public func appearFrom(_ appearFrom: AppearAnimation?) -> Self {
            self.appearFrom = appearFrom
            return self
        }

        public func disappearTo(_ disappearTo: AppearAnimation?) -> Self {
            self.disappearTo = disappearTo
            return self
        }
    }

    public class ScrollPopupParameters: BasePopupParameters {
        var headerView: () -> any View = { EmptyView() }

        public func headerView(_ headerView: @escaping () -> any View) -> Self {
            self.headerView = headerView
            return self
        }
    }
}
