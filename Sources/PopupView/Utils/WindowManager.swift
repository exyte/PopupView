//
//  HostingParentController.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 02.06.2025.
//

import SwiftUI

#if os(iOS)

@MainActor
final class WindowManager {
    static let shared = WindowManager()
    private var entries: [UUID: Entry] = [:]
    
    private struct Entry {
        let window: UIWindow
        let controller: UIViewController
        private let rootViewUpdater: @MainActor (Any) -> Void

        init<Content: View>(window: UIWindow, controller: UIHostingController<Content>) {
            self.window = window
            self.controller = controller
            self.rootViewUpdater = { @MainActor newContent in
                guard let content = newContent as? Content else {
                    assertionFailure("Content type mismatch")
                    return
                }
                controller.rootView = content
            }
        }

        @MainActor func updateRootView<Content: View>(_ content: Content) {
            rootViewUpdater(content)
        }
    }

    // Show a new window with hosted SwiftUI content
    static func showInNewWindow<Content: View>(
        id: UUID,
        closeOnTapOutside: Bool,
        allowTapThroughBG: Bool,
        dismissClosure: @escaping SendableClosure,
        content: @escaping () -> Content
    ) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("No valid scene available")
            return
        }

        let window = UIPassthroughWindow(
            windowScene: scene,
            closeOnTapOutside: closeOnTapOutside,
            isPassthrough: allowTapThroughBG,
            dismissClosure: dismissClosure
        )

        window.backgroundColor = .clear

        let rootView = content()
            .environment(\.popupDismiss, dismissClosure)

        let controller = if #available(iOS 18, *) {
            UIHostingController(rootView: rootView)
        } else {
            UITextFieldCheckingVC(rootView: rootView)
        }

        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()

        // Store window and controller reference
        shared.entries[id] = Entry(window: window, controller: controller)
    }

    static func updateRootView<Content: View>(
        id: UUID,
        dismissClosure: @escaping () -> (),
        content: @escaping () -> Content
    ) {
        guard let entry = shared.entries[id] else { return }

        let rootView = content()
            .environment(\.popupDismiss) {
                dismissClosure()
            }
        entry.updateRootView(rootView)
    }

    static func closeWindow(id: UUID) {
        shared.entries[id]?.window.isHidden = true
        shared.entries.removeValue(forKey: id)
    }
}

class UIPassthroughWindow: UIWindow {
    var closeOnTapOutside: Bool
    var isPassthrough: Bool
    var dismissClosure: SendableClosure?
    
    init(windowScene: UIWindowScene, closeOnTapOutside: Bool, isPassthrough: Bool, dismissClosure: SendableClosure?) {
        self.closeOnTapOutside = closeOnTapOutside
        self.isPassthrough = isPassthrough
        self.dismissClosure = dismissClosure
        super.init(windowScene: windowScene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let vc = rootViewController else {
            return nil
        }
        vc.view.layoutIfNeeded() // otherwise the frame is as if the popup is still outside the screen

        for subview in vc.view.subviews {
            if classNameContains(subview, "PopupHitRegion"),
               subview.frame.contains(point) {
                return vc.view // let UIKit pass this touch to wrapped SwiftUI view in regular manner
            }
        }

        // here we know the tap was outside the actual popup's body, meaning the background was tapped

        if closeOnTapOutside {
            dismissClosure?()
        }

        if isPassthrough {
            return nil // pass to next window
        }
        return vc.view
    }

    private func classNameContains(_ view: UIView, _ string: String) -> Bool {
        String(describing: view.self).contains(string)
    }
}

final class BGHitRegionView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        true
    }
}

struct BGHitRegion: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        BGHitRegionView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


final class PopupHitRegionView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        true
    }
}

struct PopupHitRegion: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        PopupHitRegionView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class UITextFieldCheckingVC<Content: View>: UIHostingController<Content> {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard #available(iOS 18, *) else {
            // manually force open the keyboard for text fields, this is an ios17 bug
            checkForTextFields(touches)
            return
        }
    }

    // Helper function to determine if any touch is inside a subview
    private func checkForTextFields(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: self.view)
        isTouchInsideSubviews(self.view, touchLocation)
    }

    private func isTouchInsideSubviews(_ view: UIView, _ touchLocation: CGPoint) {
        for subview in view.subviews {
            let localPoint = subview.convert(touchLocation, from: self.view)
            if subview.isUserInteractionEnabled, subview.frame.contains(localPoint), let textField = subview as? UITextField {
                textField.becomeFirstResponder()
                return
            }
            if !subview.subviews.isEmpty {
                isTouchInsideSubviews(subview, touchLocation)
            }
        }
    }
}
#endif
