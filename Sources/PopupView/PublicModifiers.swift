//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

public typealias SendableClosure = @Sendable @MainActor () -> Void

struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: SendableClosure? = nil
}

public extension EnvironmentValues {
    var popupDismiss: SendableClosure? {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

struct PopupSafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

public extension EnvironmentValues {
    /// The device's current safe area, kept up to date across rotation and window/safe-area changes.
    /// Types that always ignore the safe area (`.toast`) never inset themselves automatically so their
    /// background can bleed to the screen edges — read this to inset your own content when needed.
    var popupSafeAreaInsets: EdgeInsets {
        get { self[PopupSafeAreaInsetsKey.self] }
        set { self[PopupSafeAreaInsetsKey.self] = newValue }
    }
}

@MainActor
extension View {
    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup.PopupTypeParameters) -> Popup.PopupTypeParameters = { $0 }
        ) -> some View {
            self.modifier(
                PopupModifier<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup.PopupTypeParameters()),
                    view: view,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup.PopupTypeParameters) -> Popup.PopupTypeParameters = { $0 }
        ) -> some View {
            self.modifier(
                PopupModifier<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup.PopupTypeParameters()),
                    view: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

    public func scrollPopup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        header: @escaping () -> any View = { EmptyView() },
        customize: @escaping (Popup.ScrollPopupParameters) -> Popup.ScrollPopupParameters = { $0 }
    ) -> some View {
        let params = customize(Popup.ScrollPopupParameters()).headerView(header)

        return self.modifier(
            PopupModifier<Int, PopupContent>(
                isPresented: isPresented,
                isBoolMode: true,
                params: params,
                view: view,
                itemView: nil)
        )
        .environment(\.popupDismiss) {
            isPresented.wrappedValue = false
        }
    }

    public func scrollPopup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        header: @escaping () -> any View = { EmptyView() },
        customize: @escaping (Popup.ScrollPopupParameters) -> Popup.ScrollPopupParameters = { $0 }
    ) -> some View {
        let params = customize(Popup.ScrollPopupParameters()).headerView(header)

        return self.modifier(
            PopupModifier<Item, PopupContent>(
                item: item,
                isBoolMode: false,
                params: params,
                view: nil,
                itemView: itemView)
        )
        .environment(\.popupDismiss) {
            item.wrappedValue = nil
        }
    }
}
