//
//  Utils.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 01.06.2022.
//  Copyright © 2022 Exyte. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

@MainActor
struct ScreenUtils {
    static var bounds: CGRect {
#if os(watchOS)
        return WKInterfaceDevice.current().screenBounds
#elseif os(macOS)
        return NSApplication.shared.keyWindow?.frame
        ?? NSScreen.main?.frame
        ?? .zero
#else
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        return scene?.screen.bounds
        ?? UIScreen.main.bounds
        ?? .zero
#endif
    }

    static var width: CGFloat {
        bounds.width
    }

    static var height: CGFloat {
        bounds.height
    }

    static var safeAreaInsets: UIEdgeInsets {
#if os(iOS) || os(tvOS)
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow?
            .safeAreaInsets ?? .zero
#else
        return .zero
#endif
    }
}

extension CGPoint {

    @MainActor
    static var pointFarAwayFromScreen: CGPoint {
        CGPoint(x: 2 * ScreenUtils.width, y: 2 * ScreenUtils.height)
    }
}

final class DispatchWorkHolder {
    var work: DispatchWorkItem?
}

final class ClassReference<T> {
    var value: T

    init(_ value: T) {
        self.value = value
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

    @ViewBuilder
    func applyIfNotNil<V: View, Value>(_ value: Value?, @ViewBuilder _ apply: (_ view: Self, Value) -> V) -> some View {
        if let value {
            apply(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyIfNotNil<V: View, Value>(_ value: Value?, if condition: (_ value: Value) -> Bool, @ViewBuilder apply: (_ view: Self) -> V) -> some View {
        if let value, condition(value) {
            apply(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyIfNotTV<V: View>(if condition: Bool, @ViewBuilder _ apply: (_ view: Self) -> V) -> some View {
#if os(tvOS)
        self
#else
        if condition {
            apply(self)
        } else {
            self
        }
#endif
    }

    @ViewBuilder
    func addTapIfNotTV(if condition: Bool, onTap: @escaping ()->()) -> some View {
#if os(tvOS)
        self
#else
        if condition {
            self.gesture(
                TapGesture().onEnded {
                    onTap()
                }
            )
        } else {
            self
        }
#endif
    }
}

// MARK: - FrameGetter

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect
    var id: String?

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            if let id {
                                print(id, self.frame, rect)
                            }
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

internal extension View {
    func frameGetter(_ frame: Binding<CGRect>, id: String? = nil) -> some View {
        modifier(FrameGetter(frame: frame, id: id))
    }
}

// MARK: - Orientation change

#if os(iOS)

@MainActor
extension View {
    func onOrientationChange(isLandscape: Binding<Bool>, onOrientationChange: @escaping () -> Void) -> some View {
        self.modifier(OrientationChangeModifier(isLandscape: isLandscape, onOrientationChange: onOrientationChange))
    }
}

@MainActor
struct OrientationChangeModifier: ViewModifier {
    @Binding var isLandscape: Bool
    let onOrientationChange: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .receive(on: DispatchQueue.main)
            ) { _ in
                updateOrientation()
            }
            .onChange(of: isLandscape) {
                onOrientationChange()
            }
    }

    private func updateOrientation() {
        let newIsLandscape = UIDevice.current.orientation.isLandscape
        if newIsLandscape != isLandscape {
            isLandscape = newIsLandscape
            onOrientationChange()
        }
    }
}

#endif
