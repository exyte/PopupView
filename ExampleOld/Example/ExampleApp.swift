//
//  ExampleApp.swift
//  Example
//
//  Created by Alisa Mylnikova on 08/10/2020.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
struct mainView: View {
    @State private var showing = false

    var body: some View {
        Button("Show Popup!") {
            showing = true
        }
        .popup(isPresented: $showing) {
            popupView(isPresented: $showing)
        } customize: {
            $0
                .isOpaque(true)
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .dragToDismiss(true)
                .backgroundView {
                    ZStack {
                        Color.red
                        VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialLight))
                    }
                }
        }
    }
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
struct popupView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .frame(width: 500, height: 500)
                    .cornerRadius(30) // <- there is the radius
                    .ignoresSafeArea(.all)

                VStack {
                    Text("Random text. Policy change occurs through interactions between wide external changes or shocks to the political system and the success of the ideas in the coalitions, which may cause actors in the advocacy coalition to shift coalitions.")
                        .fixedSize(horizontal: false, vertical: true)

                    NavigationLink {
                        Text("Detail View. Random text. Policy change occurs through interactions between wide external changes or shocks to the political system and the success of the ideas in the coalitions, which may cause actors in the advocacy coalition to shift coalitions.")
                    } label: {
                        Text("Detail View")
                    }

                }
                .padding(.horizontal, 50)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.4)) // <- hiding the corners
        }
        .frame(width: 500, height: 500)
    }
}
