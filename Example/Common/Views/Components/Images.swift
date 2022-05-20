//
//  ImageViews.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

private struct AlertImageView<Content> : View where Content : View {
    let hex: String
    let alignment: Alignment
    
    @ViewBuilder let content: (Color) -> Content
    
    var body: some View {
        let color = Color(hex: hex)
        return ZStack(alignment: alignment) {
            Rectangle()
                .fill(color)
                .opacity(0.24)
                .frame(width: 40, height: 40)
            content(color)
        }
        .cornerRadius(10)
    }
}

struct FloatsImage: View {
    let position: Position
    
    var body: some View {
        AlertImageView(hex: "9265F8", alignment: position.toAligment()) { color in
            Rectangle()
                .fill(color)
                .frame(width: 24, height: 4)
                .cornerRadius(12)
                .padding(.all, 8)
        }
    }
    
    enum Position {
        case top, bottom
        
        func toAligment() -> Alignment {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }
    }
}

struct ToastImage: View {
    let position: Position
    
    var body: some View {
        AlertImageView(hex: "87B9FF", alignment: position.toAligment()) { color in
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 24)
                .padding(
                    EdgeInsets(
                        top: position == .top ? -16 : 0,
                        leading: 0,
                        bottom: position == .bottom ? -16 : 0,
                        trailing: 0
                    )
                )
        }
    }
    
    enum Position {
        case top, bottom
        
        func toAligment() -> Alignment {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }
    }
}

struct PopupImage: View {
    let style: Style
    
    var body: some View {
        AlertImageView(hex: "CCE7A2", alignment: style.toAligment()) { color in
            switch style {
            case .default:
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 24, height: 20)
                
            case .bottomFirst:
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 24, height: 20)
                    .padding(.bottom, 4)
                
            case .bottomSecond:
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 40, height: 20)
                    .padding(0)
            }
        }
    }
    
    enum Style {
        case `default`
        case bottomFirst
        case bottomSecond
        
        func toAligment() -> Alignment {
            switch self {
            case .default:
                return .center
            case .bottomFirst, .bottomSecond:
                return .bottom
            }
        }
    }
}

struct ActionSheetImage: View {
    var body: some View {
        AlertImageView(hex: "FFB93D", alignment: .bottom) { color in
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 20)
                .padding(0)
        }
    }
}
