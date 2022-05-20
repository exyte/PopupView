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
