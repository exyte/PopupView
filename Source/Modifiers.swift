//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

extension View {

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        type: Popup<Item, PopupContent>.PopupType = .`default`,
        position: Popup<Item, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup(
                    item: item,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: { _ in },
                    view: view)
            )
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        type: Popup<Int, PopupContent>.PopupType = .`default`,
        position: Popup<Int, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup<Int, PopupContent>(
                    isPresented: isPresented,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: { _ in },
                    view: view)
            )
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        type: Popup<Item, PopupContent>.PopupType = .`default`,
        position: Popup<Item, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissCallback: @escaping () -> (),
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup(
                    item: item,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: { _ in dismissCallback() },
                    view: view)
            )
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        type: Popup<Int, PopupContent>.PopupType = .`default`,
        position: Popup<Int, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissCallback: @escaping () -> (),
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup<Int, PopupContent>(
                    isPresented: isPresented,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: { _ in dismissCallback() },
                    view: view)
            )
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        type: Popup<Item, PopupContent>.PopupType = .`default`,
        position: Popup<Item, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissSourceCallback: @escaping (DismissSource) -> (),
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup(
                    item: item,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: dismissSourceCallback,
                    view: view)
            )
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        type: Popup<Int, PopupContent>.PopupType = .`default`,
        position: Popup<Int, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissSourceCallback: @escaping (DismissSource) -> (),
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup<Int, PopupContent>(
                    isPresented: isPresented,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: dismissSourceCallback,
                    view: view)
            )
        }
}
