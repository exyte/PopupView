//
//  ScrollPopupModifier.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.05.2026.
//

#if os(iOS)

import SwiftUI
import UIKit

struct ScrollPopupModifier: ViewModifier {

    @ObservedObject var dragToDismissManager: DragToDismissHelper
    @Binding var sheetContentRect: CGRect
    var scrollParams: Popup.ScrollPopupParameters
    var shouldDismiss: ()->()

    @StateObject private var scrollViewDelegate = PopupScrollViewDelegate()

    @State private var scrollViewContentHeight = 0.0
    @State private var needsScrollToFit = false

    /// Once scroll's content reaches 0 offset, the same drag gesture becomes popup's dismissal gesture: this is the dismissal progress offset
    /// NOTE: This is a separate drag to dismiss gesture and offset from dragToDismissManager
    @State private var dragToDismissOffset: CGFloat = 0

    private var contentPadding: EdgeInsets {
        guard scrollViewContentHeight != 0 else { return .init() }

        switch scrollParams.position {
        case .bottom(let topPadding):
            return .init(top: topPadding, leading: 0, bottom: 0, trailing: 0)

        case .center(let verticalPadding):
            return .init(
                top: verticalPadding,
                leading: 0,
                bottom: verticalPadding,
                trailing: 0
            )
        }
    }

    public func body(content: Content) -> some View {
        VStack(spacing: -0.5) {
            if scrollViewContentHeight != 0 {
                AnyView(scrollParams.headerView())
                    .fixedSize(horizontal: false, vertical: true)
                    .applyIf(scrollParams.dragToDismiss) {
                        $0.simultaneousGesture(dragToDismissManager.dragGesture)
                    }
            }

            ScrollView {
                content
                    .background(
                        ScrollViewResolver { scrollView in
                            scrollView.bounces = false
                            configureScrollHeight(scrollView: scrollView)
                        }
                    )
                    .applyIf(scrollParams.dragToDismiss && !needsScrollToFit) {
                        // if there is no scroll, there will be no scroll's UIPan gesture, so attach this one
                        $0.simultaneousGesture(dragToDismissManager.dragGesture)
                    }
            }
            .frame(maxHeight: scrollViewContentHeight)
        }
        .padding(contentPadding)
        .offset(y: dragToDismissOffset)
        .offset(dragToDismissManager.dragTranslation)
    }

    private func configureScrollHeight(scrollView: UIScrollView) {
        Task {
            await MainActor.run {
                scrollViewContentHeight = scrollView.contentSize.height
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                needsScrollToFit = scrollView.bounds.height < scrollViewContentHeight
                if scrollParams.dragToDismiss, needsScrollToFit {
                    self.configureScrollDelegate(scrollView: scrollView)
                }
            }
        }
    }

    private func configureScrollDelegate(scrollView: UIScrollView) {
        scrollViewDelegate.setScrollView(scrollView)

        scrollViewDelegate.onDragChanged = { value in
            dragToDismissOffset = value
        }

        let referenceY = sheetContentRect.height / 3
        scrollViewDelegate.onDragEnded = { value in
            if scrollParams.dragToDismiss && value >= referenceY {
                DispatchQueue.main.async {
                    shouldDismiss()
                }
            } else {
                withAnimation {
                    dragToDismissOffset = .zero
                }
            }
        }
        scrollView.bounces = false
    }
}

@MainActor
final class PopupScrollViewDelegate: ObservableObject {
    var onDragChanged: (Double) -> Void = {_ in }
    var onDragEnded: (Double) -> Void = {_ in }

    private var scrollView: UIScrollView?
    private let keyboardHeightHelper = KeyboardHeightHelper()

    private var initialTranslation: CGPoint?

    func setScrollView(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
        scrollView.bounces = false

        guard let gestures = scrollView.gestureRecognizers else { return }
        let panGesture = gestures.compactMap({ $0 as? UIPanGestureRecognizer }).first
        panGesture?.addTarget(self, action: #selector(handlePan))
    }

    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scrollView)
        let contentOffset = scrollView?.contentOffset.y ?? 0

        // Once scroll's content reaches 0 offset, the same drag gesture becomes popup's dismissal gesture

        // preserve translation at the moment when scroll's content reaches 0 offset
        // from now on translation doesn't influnce scroll's contentOffset, but is passed to dismiss mechanism
        if contentOffset == 0, initialTranslation == nil {
            initialTranslation = translation
        }

        // if user scroll back to where dismissal started, start passing translation back to contentOffset and reset dismissal progress
        if let initialTranslation, translation.y < initialTranslation.y {
            self.initialTranslation = nil
            onDragChanged(0)
        }

        // non-nil initialTranslation means that dismissal is in progress, pass it to dismiss mechanism
        if let initialTranslation {
            onDragChanged(translation.y - initialTranslation.y)
        }

        if gesture.state == .ended, let initialTranslation {
            onDragEnded(translation.y - initialTranslation.y)
            self.initialTranslation = nil
        }
    }
}

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
