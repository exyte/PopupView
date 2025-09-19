//
//  HostingParentController.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 02.06.2025.
//

import SwiftUI

#if os(iOS)

@MainActor
public final class WindowManager {
    static let shared = WindowManager()
    var windows: [UUID: UIWindow] = [:]

    // Show a new window with hosted SwiftUI content
    public static func showInNewWindow<Content: View>(id: UUID, allowTapThroughBG: Bool, dismissClosure: @escaping ()->(), content: @escaping () -> Content) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("No valid scene available")
            return
        }

        let window = allowTapThroughBG ? UIPassthroughWindow(windowScene: scene) : UIWindow(windowScene: scene)
        window.backgroundColor = .clear

        let root = content()
            .environment(\.popupDismiss) {
                dismissClosure()
            }
        let controller: UIViewController
        if #available(iOS 18, *) {
            controller = UIHostingController(rootView: root)
        } else {
            controller = UITextFieldCheckingVC(rootView: root)
        }
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
            
            let pointInRoot = vc.view.convert(point, from: self)
            
            // iOS26 Passthrough Find Issue
            if #available(iOS 26, *), vc.view.point(inside: pointInRoot, with: event) {
                return vc.view
            }
            if let _ = isTouchInsideSubview(point: pointInRoot, view: vc.view) {
                // pass tap to this UIPassthroughVC
                return vc.view
            }
        }
        return nil // pass to next window
    }

    private func isTouchInsideSubview(point: CGPoint, view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isUserInteractionEnabled, subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
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
