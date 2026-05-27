//
//  with.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.03.2025.
//

import SwiftUI

/// this is a separe struct with @Bindings because of how UIWindow doesn't receive updates in usual SwiftUI manner
struct PopupBackgroundView: View {

    @Binding var animatableOpacity: CGFloat
    
    var shouldDismiss: ()->()

    var isWindowMode: Bool
    var backgroundColor: Color?
    var backgroundView: AnyView?
    var closeOnTapOutside: Bool
    var allowTapThroughBG: Bool
    var dismissEnabled: Binding<Bool>

    var body: some View {
        ZStack {
#if os(watchOS) || os(macOS)
            contentView()
                .applyIf(closeOnTapOutside) { view in
                    view.contentShape(Rectangle())
                }
                .addTapIfNotTV(if: closeOnTapOutside) {
                    if dismissEnabled.wrappedValue {
                        shouldDismiss()
                    }
                }
#else
            contentView()
                .applyIf(closeOnTapOutside && !isWindowMode) { view in
                    view.contentShape(Rectangle())
                }
                .addTapIfNotTV(if: closeOnTapOutside && !isWindowMode) {
                    if dismissEnabled.wrappedValue {
                        shouldDismiss()
                    }
                }
#endif
        }
    }

    func contentView() -> some View {
        Group {
            if let backgroundView {
                backgroundView
            } else if let backgroundColor {
                backgroundColor
            }
        }
        .allowsHitTesting(!allowTapThroughBG)
        .opacity(animatableOpacity)
        .edgesIgnoringSafeArea(.all)
        .animation(.linear(duration: 0.2), value: animatableOpacity)
    }
}
