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
                        NavigationLink("Types example") {
                            PopupTypesView()
                        }
                        
                        NavigationLink("Modes example") {
                            PopupModesView()
                        }
                    }
                }
                .navigationTitle("Popup examples")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
