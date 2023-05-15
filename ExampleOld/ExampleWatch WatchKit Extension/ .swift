//
//  ExampleApp.swift
//  ExampleWatch WatchKit Extension
//
//  Created by Alisa Mylnikova on 17/08/2020.
//

import SwiftUI

@main
struct ExampleApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
