//
//  with.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.03.2025.
//

import SwiftUI

/// this is a separe struct with @Bindings because of how UIWindow doesn't receive updates in usual SwiftUI manner
struct PopupBackgroundView<Item: Equatable>: View {

    @Binding var id: UUID
    
    @Binding var isPresented: Bool
    @Binding var item: Item?

    @Binding var animatableOpacity: CGFloat
    @Binding var dismissSource: DismissSource?

    var backgroundColor: Color
    var backgroundView: AnyView?
    var closeOnTapOutside: Bool

    var body: some View {
        Group {
            if let backgroundView = backgroundView {
                backgroundView
            } else {
                backgroundColor
            }
        }
        .opacity(animatableOpacity)
        .applyIf(closeOnTapOutside) { view in
            view.contentShape(Rectangle())
        }
        .addTapIfNotTV(if: closeOnTapOutside) {
            dismissSource = .tapOutside
            isPresented = false
            item = nil
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.linear(duration: 0.2), value: animatableOpacity)
    }
}
