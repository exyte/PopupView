//
//  Utils.swift
//  Example
//
//  Created by Alisa Mylnikova on 10/06/2021.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

extension View {
    
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
    
    func customButtonStyle(
        foreground: Color = .black,
        background: Color = .white
    ) -> some View {
        self.buttonStyle(
            ExampleButtonStyle(
                foreground: foreground,
                background: background
            )
        )
    }

#if os(iOS)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
#endif
}

private struct ExampleButtonStyle: ButtonStyle {
    let foreground: Color
    let background: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.45 : 1)
            .foregroundColor(configuration.isPressed ? foreground.opacity(0.55) : foreground)
            .background(configuration.isPressed ? background.opacity(0.55) : background)
    }
}

#if os(iOS)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

class Constants {
    static let privacyPolicy = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam consectetur orci eget rutrum dignissim. Vivamus aliquam a massa a scelerisque. Integer eleifend lectus non blandit ultricies. Maecenas volutpat neque ut elit facilisis sodales. Mauris et iaculis tellus. Etiam nec mi consequat, ornare quam in, ornare magna. Donec quis egestas nunc. Morbi vel orci leo. Suspendisse eget lectus a erat dignissim interdum et quis neque. Fusce dapibus rhoncus nulla. Cras sed ipsum congue, tempus mi nec, vestibulum lorem.

Mauris rutrum urna ex, eget bibendum lectus vehicula nec. Mauris quis porttitor sapien, id vestibulum nibh. Proin mi lectus, pretium sed nulla bibendum, fringilla dignissim lacus. Vestibulum eget ante quis urna facilisis tristique. Curabitur mollis cursus mauris, vitae sollicitudin lacus fermentum nec. Etiam accumsan venenatis feugiat. Curabitur vitae posuere quam, imperdiet mattis elit. Nulla sollicitudin non neque sed aliquet. Donec lobortis iaculis interdum.

Nam eu feugiat arcu. Suspendisse porta eu sapien et eleifend. Fusce viverra laoreet tellus, eget convallis odio. Vivamus eget mollis dui. Sed euismod sed justo in fermentum. Nam at augue convallis, vulputate ligula eu, convallis risus. Proin egestas pretium nibh, in blandit ipsum varius quis. Aenean dolor mauris, luctus vel consequat id, tristique sit amet sem. Donec at pulvinar sem. Mauris diam lacus, placerat eget dolor ac, hendrerit elementum velit.

Integer sagittis ultricies commodo. Nullam eu diam at justo ornare viverra. Praesent ante metus, rhoncus ac condimentum id, malesuada viverra arcu. Nunc porta, odio at elementum viverra, tortor sem placerat lacus, eget scelerisque turpis odio at nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla varius luctus ex, eu sagittis leo tempor nec. Etiam viverra molestie iaculis. Fusce in cursus ipsum, et elementum metus. Nullam sed sodales ligula. Aliquam erat volutpat. Proin mattis nisi et lectus rutrum, quis aliquet metus aliquet. Nulla est nisi, condimentum sed pretium ac, scelerisque semper eros. Nullam varius diam at augue vehicula elementum eget a leo. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam nisi enim, euismod ac tellus at, hendrerit dignissim turpis. Proin sit amet sapien posuere, facilisis velit quis, placerat purus.

Maecenas eget felis in lacus pharetra tristique. Nunc vehicula porttitor dolor, non viverra magna blandit sit amet. Phasellus et pellentesque ante, at sollicitudin leo. Etiam at quam nec ex rhoncus sagittis. Nullam tempor lectus id felis efficitur tempus eget eget lectus. Mauris vitae odio nisi. Fusce pellentesque mattis enim, vitae tincidunt nisl tempus sed. Sed et lacus vitae lectus pretium congue nec molestie odio. Phasellus nec libero ac enim consequat dapibus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi suscipit, urna vel elementum consequat, eros urna tempor nulla, vel mattis arcu ex quis nisl. Phasellus consequat porta lectus, eu tristique ipsum laoreet sit amet. Nam scelerisque ipsum sem, vitae sodales risus gravida in.

Maecenas felis velit, sodales ut diam vitae, sagittis aliquet neque. Duis tristique nisl at tristique hendrerit. Suspendisse sed egestas orci. Phasellus tempor cursus tellus, eget rhoncus justo mattis id. In a dapibus enim. Nulla eu neque tincidunt tellus finibus mattis. Mauris congue tellus vitae tortor laoreet accumsan.

Aenean iaculis porta consectetur. Vivamus tristique erat consectetur mi congue sollicitudin. Donec pellentesque, arcu pellentesque rhoncus vestibulum, massa diam vehicula nulla, non lacinia nunc lacus ut felis. Nam euismod finibus quam nec placerat. In imperdiet egestas sapien, sed elementum purus. Nullam interdum nisl fermentum ultrices elementum. Quisque eu mi sapien. Morbi vestibulum urna vel lacinia ultrices. Ut urna tortor, luctus in lorem eget, euismod volutpat magna. Etiam a accumsan massa. Fusce finibus blandit diam ac tincidunt. Nullam vitae dolor augue.

Maecenas maximus feugiat tellus sed vulputate. Proin ut ante vitae justo pulvinar laoreet. Donec fringilla justo consectetur mi consequat porttitor. Sed at mollis metus. Quisque at magna quis est malesuada aliquam sit amet at augue. Mauris hendrerit nunc ligula, in faucibus erat commodo quis. Nulla lacus dolor, cursus quis ligula eu, lacinia sollicitudin felis. Praesent odio tellus, pellentesque vitae leo ac, faucibus facilisis augue. Pellentesque bibendum nisl eget vehicula convallis. Maecenas velit urna, hendrerit quis nulla vitae, aliquam posuere erat. Integer accumsan sed arcu nec tempus. Etiam pharetra suscipit sapien id venenatis. Donec ultricies quis nisi vitae consectetur.
"""
}
