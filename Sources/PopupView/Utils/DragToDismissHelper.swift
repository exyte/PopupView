//
//  DragToDismissHelper.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 28.05.2026.
//

#if !os(tvOS)

import SwiftUI

@MainActor
class DragToDismissHelper: ObservableObject {

    @Published var dragTranslation: CGSize = .zero

    @Binding var sheetContentRect: CGRect
    @Binding var isDragging: Bool
    @Binding var timeToHide: Bool

    var params: Popup.BasePopupParameters
    var appearFrom: Popup.AppearAnimation
    var shouldDismiss: ()->()

    var dragGesture: some Gesture {
        SimpleDragGesture { isDragging in
            self.isDragging = isDragging
            if !isDragging {
                self.onDragEnded()
            }
        } onTranslationChanged: {
            self.dragTranslation = self.limitToDismissDirection($0)
        }
    }

    init() {
        self._sheetContentRect = .constant(.zero)
        self._isDragging = .constant(false)
        self._timeToHide = .constant(false)

        self.params = Popup.BasePopupParameters()
        self.appearFrom = .none
        self.shouldDismiss = { }
    }

    func configure(
        sheetContentRect: Binding<CGRect>,
        isDragging: Binding<Bool>,
        timeToHide: Binding<Bool>,
        params: Popup.BasePopupParameters,
        appearFrom: Popup.AppearAnimation,
        shouldDismiss: @escaping () -> Void
    ) {
        self._sheetContentRect = sheetContentRect
        self._isDragging = isDragging
        self._timeToHide = timeToHide

        self.params = params
        self.appearFrom = appearFrom
        self.shouldDismiss = shouldDismiss
    }

    func limitToDismissDirection(_ translation: CGSize) -> CGSize {
        switch appearFrom {
        case .topSlide:
            if translation.height < 0 {
                return CGSize(width: 0, height: translation.height)
            }
        case .bottomSlide:
            if translation.height > 0 {
                return CGSize(width: 0, height: translation.height)
            }
        case .leftSlide:
            if translation.width < 0 {
                return CGSize(width: translation.width, height: 0)
            }
        case .rightSlide:
            if translation.width > 0 {
                return CGSize(width: translation.width, height: 0)
            }
        case .centerScale, .none:
            return .zero
        }
        return .zero
    }

    private func onDragEnded() {
        isDragging = false

        var referenceX = sheetContentRect.width / 3
        var referenceY = sheetContentRect.height / 3

        if let dragToDismissDistance = params.dragToDismissDistance {
            referenceX = dragToDismissDistance
            referenceY = dragToDismissDistance
        }

        var shouldDismiss = false
        switch appearFrom {
        case .topSlide:
            if dragTranslation.height < -referenceY {
                shouldDismiss = true
            }
        case .bottomSlide:
            if dragTranslation.height > referenceY {
                shouldDismiss = true
            }
        case .leftSlide:
            if dragTranslation.width < -referenceX {
                shouldDismiss = true
            }
        case .rightSlide:
            if dragTranslation.width > referenceX {
                shouldDismiss = true
            }
        case .centerScale, .none:
            break
        }

        if timeToHide { // autohide timer was finished while the user was dragging
            timeToHide = false
            shouldDismiss = true
        }

        if params.dismissEnabled.wrappedValue, shouldDismiss {
            self.shouldDismiss()
        } else {
            withAnimation {
                dragTranslation = .zero
            }
        }
    }
}

struct SimpleDragGesture: Gesture {

    var onDraggingChanged: (Bool) -> () // drag started/finished
    var onTranslationChanged: (CGSize) -> ()

    @GestureState private var gestureTranslation: CGSize = .zero
    @State private var isDragging = false

    var body: some Gesture {
        DragGesture(coordinateSpace: .global)
            .updating($gestureTranslation) { value, state, _ in
                state = value.translation

                DispatchQueue.main.async {
                    onTranslationChanged(value.translation)
                }
            }
            .onChanged { _ in
                if !isDragging {
                    isDragging = true
                    onDraggingChanged(true)
                }
            }
            .onEnded { value in
                onTranslationChanged(value.translation)
                onDraggingChanged(false)
            }
    }
}

#endif
