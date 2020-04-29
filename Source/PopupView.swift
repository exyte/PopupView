//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

extension View {

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        type: Popup<PopupContent>.PopupType = .`default`,
        position: Popup<PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        closeOnTap: Bool = true,
        view: @escaping () -> PopupContent) -> some View {
        self.modifier(
            Popup(
                isPresented: isPresented,
                type: type,
                position: position,
                animation: animation,
                autohideIn: autohideIn,
                closeOnTap: closeOnTap,
                view: view)
        )
    }
}

public struct Popup<PopupContent>: ViewModifier where PopupContent: View {

    public enum PopupType {

        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 20)

        func shouldBeCentered() -> Bool {
            switch self {
            case .`default`:
                return true
            default:
                return false
            }
        }
    }

    public enum Position {

        case top
        case bottom
    }

    // MARK: - Public Properties

    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool

    var type: PopupType
    var position: Position

    var animation: Animation

    /// If nil - niver hides on its own
    var autohideIn: Double?

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

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
        switch type {
        case .`default`:
            return 0
        case .toast:
            if position == .bottom {
                return presenterContentRect.height - sheetContentRect.height + safeAreaInset.bottom
            } else {
                return sheetContentRect.height - presenterContentRect.height - safeAreaInset.top
            }
        case .floater(let verticalPadding):
            if position == .bottom {
                return presenterContentRect.height - sheetContentRect.height - verticalPadding
            } else {
                return sheetContentRect.height - presenterContentRect.height + verticalPadding
            }
        }
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if position == .top {
            return -UIScreen.main.bounds.height - 5
        } else {
            return UIScreen.main.bounds.height + 5
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return isPresented ? displayedOffset : hiddenOffset
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
                self.isPresented = false
            })
            if isPresented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }

        return ZStack {
            Group {
                VStack {
                    if type.shouldBeCentered() || position == .top {
                        Spacer()
                    }

                    VStack {
                        self.view()
                            .simultaneousGesture(TapGesture().onEnded {
                                if self.closeOnTap {
                                    self.isPresented = false
                                }
                            })
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

                    if type.shouldBeCentered() || position == .bottom {
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

class DispatchWorkHolder {
    var work: DispatchWorkItem?
}
