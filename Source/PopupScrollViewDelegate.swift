//
//  PopupScrollViewDelegate.swift
//
//
//  Created by vadim.vitkovskiy on 15.02.2024.
//

import UIKit

extension UIScrollView {
    func maxContentOffsetHeight() -> CGFloat {
        let contentHeight = contentSize.height
        let visibleHeight = bounds.height
        let maxOffsetHeight = max(0, contentHeight - visibleHeight)
        return maxOffsetHeight
    }
}

final class PopupScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {

    var scrollView: UIScrollView?

    var dragGesture: UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return panGesture
    }

    var didReachTop: (Double) -> Void = {_ in }
    var scrollEnded: (Double) -> Void = {_ in }

    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scrollView)
        let contentOffset = scrollView?.contentOffset.y ?? 0
        let maxContentOffset = scrollView?.maxContentOffsetHeight() ?? 0

        if contentOffset - translation.y > 0 {
            scrollView?.contentOffset.y = min(contentOffset - translation.y, maxContentOffset)
            gesture.setTranslation(.zero, in: scrollView)
        } else {
            scrollView?.contentOffset.y = 0
            didReachTop(contentOffset - translation.y)
        }
        
        if gesture.state == .ended && contentOffset - translation.y < 0 {
            scrollEnded(contentOffset - translation.y)
        }
    }

    func addGestureIfNeeded() {
        guard let gestures = scrollView?.gestureRecognizers,
              let gesture = gestures.last else { return }


        if !(gesture is UIPanGestureRecognizer) {
            scrollView?.addGestureRecognizer(dragGesture)
        }
    }

}
