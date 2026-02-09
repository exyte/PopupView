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
    
    private struct Entry {
        let window: UIWindow
        let controller: (UIViewController & AnyViewHostingController)
    }
    
    private var entries: [UUID: Entry] = [:]

    // Show a new window with hosted SwiftUI content
    public static func showInNewWindow(
        id: UUID,
        closeOnTapOutside: Bool,
        allowTapThroughBG: Bool,
        dismissClosure: @escaping ()->(),
        content: @escaping () -> AnyView
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

        let root = AnyView(
            content()
                .environment(\.popupDismiss) {
                    dismissClosure()
                }
        )
        
        let controller: (UIViewController & AnyViewHostingController)
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
        shared.entries[id] = Entry(window: window, controller: controller)
    }

    public static func updateRootView(id: UUID, dismissClosure: @escaping () -> (), content: @escaping () -> AnyView) {
        guard let entry = shared.entries[id] else { return }
        
        entry.controller.rootView = AnyView(
            content()
                .environment(\.popupDismiss) {
                    dismissClosure()
                }
        )
    }

    static func closeWindow(id: UUID) {
        shared.entries[id]?.window.isHidden = true
        shared.entries.removeValue(forKey: id)
    }
}

protocol AnyViewHostingController: AnyObject {
    var rootView: AnyView { get set }
}

extension UIHostingController: AnyViewHostingController where Content == AnyView {}

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
        guard let vc = self.rootViewController else {
            return nil // pass to next window
        }

        vc.view.layoutIfNeeded() // otherwise the frame is as if the popup is still outside the screen

        let layerHitTestResult = vc.view.layer.hitTest(vc.view.convert(point, from: self))
        let superlayerDelegateName = layerHitTestResult?.superlayer?.delegate.map { String(describing: type(of: $0)) }
        let didTapBackground = superlayerDelegateName?.contains(String(describing: PopupHitTestingBackground.self)) ?? false

        if didTapBackground {
            if closeOnTapOutside {
                dismissClosure?()
            }
            
            if isPassthrough {
                return nil // pass to next window
            }
            return vc.view
        }
        
        // pass tap to this
        let farthestDescendent = super.hitTest(point, with: event)
        return farthestDescendent
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
