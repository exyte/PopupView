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

    var body: some Scene {
        WindowGroup {
#if os(iOS)
            NavigationView {
                List {
                    Section {
                        NavigationLink("Github example") {
                            GithubExampleView()
                        }

                        NavigationLink("Position examples") {
                            PositionExamplesView()
                        }

                        NavigationLink("BG taps examples") {
                            BGTapsExamplesView()
                        }
                        NavigationLink("Scroll examples") {
                            ScrollExamplesView()
                        }

                        NavigationLink("Misc examples") {
                            MiscExamplesView()
                        }
                    }
                }
                .navigationTitle("Popup examples")
                .navigationBarTitleDisplayMode(.inline)
            }
#else
            GithubExampleView()
#endif
        }
    }
}
