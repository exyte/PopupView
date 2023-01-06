//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

extension View {

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<Int, PopupContent>.PopupParameters) -> Popup<Int, PopupContent>.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup<Int, PopupContent>.PopupParameters()),
                    view: view)
            )
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        customize: @escaping (Popup<Item, PopupContent>.PopupParameters) -> Popup<Item, PopupContent>.PopupParameters,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup<Item, PopupContent>.PopupParameters()),
                    view: view)
            )
        }
}
