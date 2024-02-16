//
//  PopupScrollViewDelegate.swift
//
//
//  Created by vadim.vitkovskiy on 15.02.2024.
//

import UIKit

final class PopupScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {

    var didEndDragging = {}

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -50 {
            didEndDragging()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -10 {
            didEndDragging()
        }
    }
}
