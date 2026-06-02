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
            NavigationView {
                List {
                    Section {
                        NavigationLink("Github example") {
                            GithubExampleView()
                        }

                        NavigationLink("Position examples") {
                            PositionExamplesView()
                        }

                        NavigationLink("Scroll examples") {
                            ScrollExamplesView()
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
