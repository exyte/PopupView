//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

public typealias SendableClosure = @Sendable @MainActor () -> Void

struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: SendableClosure? = nil
}

public extension EnvironmentValues {
    var popupDismiss: SendableClosure? {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

extension View {

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup<PopupContent>.PopupParameters()),
                    view: view,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup<PopupContent>.PopupParameters()),
                    view: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: Popup<PopupContent>.PopupParameters(),
                    view: view,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: Popup<PopupContent>.PopupParameters(),
                    view: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }
}

#if os(iOS)

extension View {
  func onOrientationChange(isLandscape: Binding<Bool>, onOrientationChange: @escaping () -> Void) -> some View {
    self.modifier(OrientationChangeModifier(isLandscape: isLandscape, onOrientationChange: onOrientationChange))
  }
}

struct OrientationChangeModifier: ViewModifier {
    @Binding var isLandscape: Bool
    let onOrientationChange: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
#if os(iOS)
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    DispatchQueue.main.async {
                        updateOrientation()
                    }
                }
                updateOrientation()
#endif
            }
            .onDisappear {
                #if os(iOS)
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
                #endif
            }
            .onChange(of: isLandscape) { _ in
                onOrientationChange()
            }
    }

#if os(iOS)
    private func updateOrientation() {
        DispatchQueue.main.async {
            let newIsLandscape = UIDevice.current.orientation.isLandscape
            if newIsLandscape != isLandscape {
                isLandscape = newIsLandscape
                onOrientationChange()
            }
        }
    }
#endif
}

#endif
