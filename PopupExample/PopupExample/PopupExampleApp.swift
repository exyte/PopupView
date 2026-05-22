//
//  PopupExampleApp.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 04.05.2023.
//

import SwiftUI
import PopupView

@main
struct PopupExampleApp: App {
    @State private var a: EdgeInsets = EdgeInsets()
    @State private var b: EdgeInsets = EdgeInsets()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    Section {
                        NavigationLink("Github example") {
                            GithubExampleView()
                                .safeAreaGetter($a)
                                .onChange(of: a) {
                                    print("a", a)
                                }
                        }

                        NavigationLink("Position examples") {
                            PositionExamplesView()
                                .safeAreaGetter($b)
                                .onChange(of: b) {
                                    print("b", b)
                                }
                        }

                        NavigationLink("BG taps examples") {
                            BGTapsExamplesView()
                        }

#if os(iOS)
                        NavigationLink("Misc examples") {
                            MiscExamplesView()
                        }
#endif
                    }
                }
                .navigationTitle("Popup examples")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
struct SafeAreaGetter: ViewModifier {

    @Binding var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let area = proxy.safeAreaInsets
                        // This avoids an infinite layout loop
                        if area != self.safeArea {
                            self.safeArea = area
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

extension View {
    public func safeAreaGetter(_ safeArea: Binding<EdgeInsets>) -> some View {
        modifier(SafeAreaGetter(safeArea: safeArea))
    }
}
