//
//  PopupScrollViewDelegate.swift
//
//
//  Created by vadim.vitkovskiy on 15.02.2024.
//

import UIKit

final class PopupScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {

    var scrollView: UIScrollView?

    func enableGestures(_ isEnable: Bool) {
        self.scrollView?.gestureRecognizers?.forEach({ gesture in
            gesture.isEnabled = isEnable
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
           enableGestures(false)
        }
    }
}
