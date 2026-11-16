#if os(macOS)
import AppKit
import Observation
import SwiftUI
import XCTest
import PopupView

/// Holds the item an item-based popup shows.
@MainActor
@Observable
private final class ItemPopupModel {
    var item: String?
}

/// Hosts an item-based popup through the public popup API.
@MainActor
private struct ItemPopupHost: View {
    @Bindable var model: ItemPopupModel

    var body: some View {
        Color.clear
            .frame(width: 640, height: 420)
            .popup(item: $model.item) { item in
                ItemPopupMarker(title: item).frame(width: 240, height: 120)
            } customize: {
                $0.type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: false))
                    .position(.bottom)
                    .closeOnTap(false)
            }
    }
}

/// A native control that can be located in the hosting hierarchy.
private struct ItemPopupMarker: NSViewRepresentable {
    let title: String

    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.identifier = NSUserInterfaceItemIdentifier("popup.item.marker")
        return button
    }

    func updateNSView(_ nsView: NSButton, context: Context) {
        nsView.title = title
    }
}

@MainActor
final class PopupItemTests: XCTestCase {
    /// An item-based popup renders while it has no item, and once it has been dismissed.
    func testItemPopupRendersWithoutItemAndAfterDismissal() async throws {
        let model = ItemPopupModel()
        let host = NSHostingView(rootView: ItemPopupHost(model: model))
        host.frame = NSRect(x: 0, y: 0, width: 640, height: 420)
        let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        window.makeKeyAndOrderFront(nil)
        defer { window.close() }
        try await Task.sleep(for: .milliseconds(100))
        host.layoutSubtreeIfNeeded()
        XCTAssertNil(marker(in: host))

        model.item = "First"
        try await Task.sleep(for: .milliseconds(450))
        host.layoutSubtreeIfNeeded()
        XCTAssertEqual(marker(in: host)?.title, "First")

        model.item = nil
        try await Task.sleep(for: .milliseconds(450))
        host.layoutSubtreeIfNeeded()
        XCTAssertNil(marker(in: host))

        model.item = "Second"
        try await Task.sleep(for: .milliseconds(450))
        host.layoutSubtreeIfNeeded()
        XCTAssertEqual(marker(in: host)?.title, "Second")
    }

    private func marker(in view: NSView) -> NSButton? {
        if view.identifier?.rawValue == "popup.item.marker" { return view as? NSButton }
        return view.subviews.lazy.compactMap { self.marker(in: $0) }.first
    }
}
#endif
