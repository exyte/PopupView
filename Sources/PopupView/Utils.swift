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
    func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { value in
                onChange(value)
            }
        }
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
            self.simultaneousGesture(
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

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

internal extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

struct SafeAreaGetter: ViewModifier {

    @Binding var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let area = proxy.safeAreaInsets
                        // This avoids an infinite layout loop
                        if area != self.safeArea {
                            self.safeArea = area
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

extension View {
    public func safeAreaGetter(_ safeArea: Binding<EdgeInsets>) -> some View {
        modifier(SafeAreaGetter(safeArea: safeArea))
    }
}

// MARK: - TransparentNonAnimatingFullScreenCover

#if os(iOS)

extension View {

    func transparentNonAnimatingFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        dismissSource: DismissSource?,
        userDismissCallback: @escaping (DismissSource) -> (),
        content: @escaping () -> Content) -> some View {
            modifier(TransparentNonAnimatableFullScreenModifier(isPresented: isPresented, dismissSource: dismissSource, userDismissCallback: userDismissCallback, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<FullScreenContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    var dismissSource: DismissSource?
    var userDismissCallback: (DismissSource) -> ()
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { isPresented in
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

// MARK: - WindowManager

#if os(iOS)

// A generic wrapper that tracks changes in the view's state
@MainActor
class HostingViewState<Content: View>: ObservableObject {
    @Published var content: Content
    let id1: UUID

    private var cancellable: AnyCancellable?

    init(content: Content, id: UUID) {
        self.content = content
        self.id1 = id
        // Subscribe to changes in the content and trigger updates
        self.cancellable = self.observeStateChanges()
    }

    private func observeStateChanges() -> AnyCancellable {
        // Observe state changes using Combine
        // You can use `Just` here for simplicity, or expand it for more complex needs.
        // In real-world cases, this would listen to any changes in the state object passed.

        return Just(content)
            .sink { [weak self] newContent in
                guard let self else { return }
                WindowManager.shared.windows[self.id1]?.rootViewController = UIHostingController(rootView: newContent)
               // self?.content = newContent // Trigger the content update when state changes
            }
    }
}

@MainActor
public final class WindowManager {
    static let shared = WindowManager()
    var windows: [UUID: UIWindow] = [:]

    // Show a new window with hosted SwiftUI content
    public static func showInNewWindow<Content: View>(id: UUID, content: @escaping () -> Content) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("No valid scene available")
            return
        }

        let window = UIPassthroughWindow(windowScene: scene)
        window.backgroundColor = .clear

        // Wrap content in an ObservableObject to track changes
        //let hostingState = HostingViewState(content: content(), id: id)

        let controller = UIPassthroughVC(rootView: content())
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()

        // Store window reference
        shared.windows[id] = window
    }

    static func closeWindow(id: UUID) {
        shared.windows[id]?.isHidden = true
        shared.windows.removeValue(forKey: id)
    }
}

class UIPassthroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let vc = self.rootViewController {
            vc.view.layoutSubviews() // otherwise the frame is as if the popup is still outside the screen
            if let _ = isTouchInsideSubview(point: point, vc: vc.view) {
                // pass tap to this UIPassthroughVC
                return vc.view
            }
        }
        return nil // pass to next window
    }

    private func isTouchInsideSubview(point: CGPoint, vc: UIView) -> UIView? {
        for subview in vc.subviews {
            if subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
}

class UIPassthroughVC<Content: View>: UIHostingController<Content> {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if any touch is inside one of the subviews, if so, ignore it
        if !isTouchInsideSubview(touches) {
            // If touch is not inside any subview, pass the touch to the next responder
            super.touchesBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesEnded(touches, with: event)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchInsideSubview(touches) {
            super.touchesCancelled(touches, with: event)
        }
    }

    // Helper function to determine if any touch is inside a subview
    private func isTouchInsideSubview(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else {
            return false
        }

        let touchLocation = touch.location(in: self.view)

        // Iterate over all subviews to check if the touch is inside any of them
        for subview in self.view.subviews {
            if subview.frame.contains(touchLocation) {
                return true
            }
        }
        return false
    }
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
        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        DispatchQueue.main.async {
            self.keyboardHeight = keyboardRect.height
            self.keyboardDisplayed = true
        }
    }
}

#else

class KeyboardHeightHelper: ObservableObject {

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false
}

#endif


// MARK: - Hide keyboard

extension CGPoint {

    @MainActor
    static var pointFarAwayFromScreen: CGPoint {
        CGPoint(x: 2*CGSize.screenSize.width, y: 2*CGSize.screenSize.height)
    }
}

extension CGSize {

    @MainActor
    static var screenSize: CGSize {
#if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#elseif os(macOS)
        return NSScreen.main?.frame.size ?? .zero
#elseif os(visionOS)
        return .zero
#endif
    }
}
