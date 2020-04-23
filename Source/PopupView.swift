//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

class DispatchWorkHolder {
    var work: DispatchWorkItem?
}

public struct Popup<PopupContent>: ViewModifier where PopupContent: View {

    public enum PopupType {
        case popup
        case bottomToast
        case topToast
        case bottomFloater(verticalPadding: CGFloat = 20)
        case topFloater(verticalPadding: CGFloat = 20)

        func isPositioned(at position: Position) -> Bool {
            switch self {
            case .bottomToast, .bottomFloater:
                return position == .bottom
            case .topToast, .topFloater:
                return position == .top
            default:
                return false
            }
        }
    }

    enum Position {
        case top
        case bottom
    }

    // MARK: - Public Properties

    /// Tells if the sheet should be presented or not
    @Binding var presented: Bool

    var popupType: PopupType

    var animation: Animation

    /// If nil - niver hides on its own
    var autohideIn: Double?

    /// Call on popup tap - default is dismissal
    var onTap: (()->())?

    var view: () -> PopupContent

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    var dispatchWorkHolder = DispatchWorkHolder()

    // MARK: - Private Properties

    /// The rect containing the content
    @State private var presenterContentRect: CGRect = .zero

    /// The rect containing the content
    @State private var sheetContentRect: CGRect = .zero

    /// The rect containing the content
    @State private var safeAreaInset = EdgeInsets()

    /// The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        switch popupType {
        case .popup:
            return 0
        case .bottomToast:
            return presenterContentRect.height - sheetContentRect.height + safeAreaInset.bottom
        case .topToast:
            return sheetContentRect.height - presenterContentRect.height - safeAreaInset.top
        case .bottomFloater(let verticalPadding):
            return presenterContentRect.height - sheetContentRect.height - verticalPadding
        case .topFloater(let verticalPadding):
            return sheetContentRect.height - presenterContentRect.height + verticalPadding
        }
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if popupType.isPositioned(at: .top) {
            return -UIScreen.main.bounds.height - 5
        } else {
            return UIScreen.main.bounds.height + 5
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return presented ? displayedOffset : hiddenOffset
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy -> AnyView in
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.presenterContentRect.integral {
                            DispatchQueue.main.async {
                                self.presenterContentRect = rect
                                self.safeAreaInset = proxy.safeAreaInsets
                            }
                        }
                        return AnyView(EmptyView())
                    }
            )
            sheet()
        }
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {

        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            dispatchWorkHolder.work?.cancel()
            dispatchWorkHolder.work = DispatchWorkItem(block: {
                self.presented = false
            })
            if presented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }

        return ZStack {
            Group {
                VStack {
                    if popupType.isPositioned(at: .top) {
                        Spacer()
                    }

                    VStack {
                        self.view()
                            .onTapGesture {
                                if let onTap = self.onTap {
                                    onTap()
                                } else {
                                    self.presented = false
                                }
                            }
                            .background(
                                GeometryReader { proxy -> AnyView in
                                    let rect = proxy.frame(in: .global)
                                    // This avoids an infinite layout loop
                                    if rect.integral != self.sheetContentRect.integral {
                                        DispatchQueue.main.async {
                                            self.sheetContentRect = rect
                                        }
                                    }
                                    return AnyView(EmptyView())
                                }
                        )
                    }

                    if popupType.isPositioned(at: .bottom) {
                        Spacer()
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: 0, y: currentOffset)
                .animation(animation)
            }
        }
    }
}

extension View {

    public func popup<PopupContent: View>(
        presented: Binding<Bool>,
        type: Popup<PopupContent>.PopupType = .bottomToast,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        onTap: (()->())? = nil,
        view: @escaping () -> PopupContent) -> some View {
        self.modifier(
            Popup(
                presented: presented,
                popupType: type,
                animation: animation,
                autohideIn: autohideIn,
                onTap: onTap,
                view: view)
        )
    }
}
