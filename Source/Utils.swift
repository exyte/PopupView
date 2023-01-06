//
//  Utils.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 01.06.2022.
//  Copyright © 2022 Exyte. All rights reserved.
//

import SwiftUI
import Combine

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

extension View {
    public func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic, Value: Comparable {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

struct AnimatableModifierDouble: AnimatableModifier {

    var targetValue: Double
    static var done = false

    // SwiftUI gradually varies it from old value to the new value
    var animatableData: Double {
        didSet {
            checkIfFinished()
        }
    }
    var completion: () -> ()

    // Re-created every time the control argument changes
    init(bindedValue: Double, completion: @escaping () -> ()) {
        self.completion = completion

        // Set animatableData to the new value. But SwiftUI again directly
        // and gradually varies the value while the body
        // is being called to animate. Following line serves the purpose of
        // associating the extenal argument with the animatableData.
        self.animatableData = bindedValue
        targetValue = bindedValue
        AnimatableModifierDouble.done = false
    }

    func checkIfFinished() -> () {
        if AnimatableModifierDouble.done { return }
        let delta = 0.1
        if animatableData > targetValue - delta &&
            animatableData < targetValue + delta {
            //print("check", animatableData, targetValue)
            AnimatableModifierDouble.done = true
            DispatchQueue.main.async {
                self.completion()
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {

    func onAnimationCompleted(for value: Double, completion: @escaping () -> Void) -> some View {
        modifier(AnimatableModifierDouble(bindedValue: value, completion: completion))
    }
}

#if os(iOS)

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

#else

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

#endif

extension View {

    func transparentNonAnimatingFullScreenCover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(TransparentNonAnimatableFullScreenModifier(isPresented: isPresented, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<FullScreenContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { isPresented in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(isPresented: $isPresented, content: {
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
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            })
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
