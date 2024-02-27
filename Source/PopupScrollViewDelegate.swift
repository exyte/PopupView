//
//  PopupScrollViewDelegate.swift
//
//
//  Created by vadim.vitkovskiy on 15.02.2024.
//

#if os(iOS)
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

    var gestureIsCreated = false

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
        guard let gestures = scrollView?.gestureRecognizers else { return }
        
        if !gestureIsCreated {
            let panGesture = gestures[1] as? UIPanGestureRecognizer
            panGesture?.addTarget(self, action: #selector(handlePan))
            scrollView?.bounces = false
            gestureIsCreated = true
        }
    }
}
#endif
