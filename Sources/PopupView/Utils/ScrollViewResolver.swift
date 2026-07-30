//
//  ScrollViewResolver.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 24.07.2026.
//

import SwiftUI

#if os(iOS)
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
