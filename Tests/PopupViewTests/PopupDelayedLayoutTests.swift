#if os(macOS)
import AppKit
import Observation
import SwiftUI
import XCTest
@testable import PopupView

/// Control when initial popup content becomes ready without navigating or presenting again.
@MainActor
@Observable
private final class DelayedPopupModel {
    /// The presentation request passed to the public popup API.
    var isPresented = false
    /// Whether the first presentation can provide measurable content.
    var isContentReady = false
    /// The number of completed dismissal callbacks.
    var dismissCount = 0
}

/// Host delayed native content through the public popup API.
@MainActor
private struct DelayedPopupHost: View {
    /// Presentation and content state owned by the test.
    @Bindable var model: DelayedPopupModel

    /// Start with zero-sized content, then provide a measurable native control when ready.
    var body: some View {
        Color.clear
            .frame(width: 640, height: 420)
            .popup(isPresented: $model.isPresented) {
                if model.isContentReady {
                    DelayedPopupMarker().frame(width: 240, height: 120)
                } else {
                    Color.clear.frame(width: 0, height: 0)
                }
            } customize: {
                $0.type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: false))
                    .position(.bottom)
                    .appearFrom(.bottomSlide)
                    .disappearTo(.bottomSlide)
                    .closeOnTap(false)
                    .dismissCallback { model.dismissCount += 1 }
            }
    }
}

/// Use a native control to distinguish a pending request from content that remains mounted.
private struct DelayedPopupMarker: NSViewRepresentable {
    /// Create a marker that can be located in the actual hosting hierarchy.
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: "Delayed popup content", target: nil, action: nil)
        button.identifier = NSUserInterfaceItemIdentifier("popup.delayedLayout.marker")
        return button
    }

    /// The marker has no state to synchronize after creation.
    func updateNSView(_ nsView: NSButton, context: Context) {}
}

/// Protect presentations whose initial layout takes longer than the animation fallback.
@MainActor
final class PopupDelayedLayoutTests: XCTestCase {
    /// Keep a pending presentation alive and allow it to reopen after a real dismissal.
    func testFirstPresentationSurvivesDelayedLayoutAndCanReopen() async throws {
        let model = DelayedPopupModel()
        let host = NSHostingView(rootView: DelayedPopupHost(model: model))
        host.frame = NSRect(x: 0, y: 0, width: 640, height: 420)
        let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        window.makeKeyAndOrderFront(nil)
        defer { window.close() }
        try await Task.sleep(for: .milliseconds(100))

        model.isPresented = true
        // Exceed the production 0.3-second fallback without navigating or presenting again.
        try await Task.sleep(for: .milliseconds(600))
        XCTAssertTrue(model.isPresented)
        XCTAssertEqual(model.dismissCount, 0, "The animation fallback must not dismiss a presentation that is still waiting for layout.")
        model.isContentReady = true
        try await Task.sleep(for: .milliseconds(400))
        host.layoutSubtreeIfNeeded()
        XCTAssertTrue(containsMarker(in: host), "Delayed content must mount without another presentation request or a navigation round trip.")

        model.isPresented = false
        try await Task.sleep(for: .milliseconds(450))
        XCTAssertFalse(containsMarker(in: host))
        XCTAssertEqual(model.dismissCount, 1)
        model.isPresented = true
        try await Task.sleep(for: .milliseconds(450))
        XCTAssertTrue(containsMarker(in: host), "The popup must reopen after an actual dismissal.")
        XCTAssertEqual(model.dismissCount, 1)
    }

    /// Inspect actual content mounting without relying on private SwiftUI view class names.
    private func containsMarker(in view: NSView) -> Bool {
        view.identifier?.rawValue == "popup.delayedLayout.marker"
            || view.subviews.contains { containsMarker(in: $0) }
    }
}
#endif
