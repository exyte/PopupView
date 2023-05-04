//
//  PopupButton.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

struct PopupButton<Content> : View where Content : View {
    @Binding var isShowing: Bool
    
    var hideAll: () -> ()
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button {
            hideAll()
            isShowing.toggle()
        } label: {
            content()
        }
        .customButtonStyle(foreground: .black, background: .clear)
    }
}

struct ItemPopupButton<Content> : View where Content : View {
    @Binding var item: SomeItem?

    let text = "In two weeks, you did 12 workouts and burned 2671 calories. That's 566 calories more than last month. Continue at the same pace and the result will please you."
    
    var hideAll: () -> ()
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button {
            hideAll()
            item = SomeItem(value: text)
        } label: {
            content()
        }
        .customButtonStyle(foreground: .black, background: .clear)
    }
}
