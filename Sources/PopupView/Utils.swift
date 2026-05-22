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
        return UIScreen.main.bounds
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

struct MemoryAddress<T>: CustomStringConvertible {

    let intValue: Int

    var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }

    // for structures
    init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
    }
}

extension MemoryAddress where T: AnyObject {

    // for classes
    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
        // or      Int(bitPattern: Unmanaged<T>.passUnretained(classInstance).toOpaque())
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

// MARK: - TransparentNonAnimatingFullScreenCover

#if os(iOS)

extension View {

    func transparentNonAnimatingFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        dismissSource: Popup.DismissSource?,
        userDismissCallback: @escaping (Popup.DismissSource) -> (),
        content: @escaping () -> Content) -> some View {
            modifier(TransparentNonAnimatableFullScreenModifier(isPresented: isPresented, dismissSource: dismissSource, userDismissCallback: userDismissCallback, fullScreenContent: content))
        }
}

private struct TransparentNonAnimatableFullScreenModifier<FullScreenContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    var dismissSource: Popup.DismissSource?
    var userDismissCallback: (Popup.DismissSource) -> ()
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) {
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    userDismissCallback(dismissSource ?? .binding)
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {

    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#endif

// MARK: - KeyboardHeightHelper

#if os(iOS)

@MainActor
class KeyboardHeightHelper: ObservableObject {

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onKeyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        DispatchQueue.main.async {
            self.keyboardHeight = keyboardRect.height
            self.keyboardDisplayed = true
        }
    }

    @objc private func onKeyboardWillHideNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.keyboardHeight = 0
            self.keyboardDisplayed = false
        }
    }
}

#else

class KeyboardHeightHelper: ObservableObject {

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false
}

#endif

#if os(iOS)

// MARK: ScrollViewResolver

struct ScrollViewResolver: UIViewRepresentable {
    var onResolve: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let scrollView = view.enclosingScrollView() {
                onResolve(scrollView)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        var view = self.superview
        while view != nil {
            if let scroll = view as? UIScrollView {
                return scroll
            }
            view = view?.superview
        }
        return nil
    }
}

#endif

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
