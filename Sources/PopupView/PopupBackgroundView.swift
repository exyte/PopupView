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
    var allowTapThroughBG: Bool
    var dismissEnabled: Binding<Bool>

    var body: some View {
        ZStack {
            Group {
                if let backgroundView = backgroundView {
                    backgroundView
                } else {
                    backgroundColor
                }
            }
            .allowsHitTesting(!allowTapThroughBG)
            .opacity(animatableOpacity)
            .edgesIgnoringSafeArea(.all)
            .animation(.linear(duration: 0.2), value: animatableOpacity)
#if os(watchOS)
            .applyIf(closeOnTapOutside) { view in
                view.contentShape(Rectangle())
            }
            .addTapIfNotTV(if: closeOnTapOutside) {
                if dismissEnabled.wrappedValue {
                    dismissSource = .tapOutside
                    isPresented = false
                    item = nil
                }
            }
#endif
#if !os(watchOS)
            PopupHitTestingBackground() // Hit testing workaround
                .ignoresSafeArea()
#endif
        }
    }
}

#if !os(watchOS)
/// A special view to handle hit-testing on background parts of popup content
struct PopupHitTestingBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
