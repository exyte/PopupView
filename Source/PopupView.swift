//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI
import Combine

extension View {

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        type: Popup<Item, PopupContent>.PopupType = .`default`,
        position: Popup<Item, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissCallback: @escaping () -> () = {},
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup(
                    item: item,
                    type: type,
                    position: position,
                    animation: animation,
                    autohideIn: autohideIn,
                    dragToDismiss: dragToDismiss,
                    closeOnTap: closeOnTap,
                    closeOnTapOutside: closeOnTapOutside,
                    backgroundColor: backgroundColor,
                    dismissCallback: dismissCallback,
                    view: view)
            )
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        type: Popup<Int, PopupContent>.PopupType = .`default`,
        position: Popup<Int, PopupContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        closeOnTapOutside: Bool = false,
        backgroundColor: Color = Color.clear,
        dismissCallback: @escaping () -> () = {},
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
        self.modifier(
            Popup<Int, PopupContent>(
                isPresented: isPresented,
                type: type,
                position: position,
                animation: animation,
                autohideIn: autohideIn,
                dragToDismiss: dragToDismiss,
                closeOnTap: closeOnTap,
                closeOnTapOutside: closeOnTapOutside,
                backgroundColor: backgroundColor,
                dismissCallback: dismissCallback,
                view: view)
        )
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

    @ViewBuilder
    fileprivate func addTapIfNotTV(if condition: Bool, onTap: @escaping ()->()) -> some View {
        #if os(tvOS)
        self
        #else
        if condition {
            self.simultaneousGesture(
                TapGesture().onEnded {
                    onTap()
                }
            )
        } else {
            self
        }
        #endif
    }
}

public struct Popup<Item: Equatable, PopupContent: View>: ViewModifier {
    
    init(isPresented: Binding<Bool>,
         type: PopupType,
         position: Position,
         animation: Animation,
         autohideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         closeOnTapOutside: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping () -> (),
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self._item = .constant(nil)
        self.type = type
        self.position = position
        self.animation = animation
        self.autohideIn = autohideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.closeOnTapOutside = closeOnTapOutside
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view
        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    init(item: Binding<Item?>,
         type: PopupType,
         position: Position,
         animation: Animation,
         autohideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         closeOnTapOutside: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping () -> (),
         view: @escaping () -> PopupContent) {
        self._isPresented = .constant(false)
        self._item = item
        self.type = type
        self.position = position
        self.animation = animation
        self.autohideIn = autohideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.closeOnTapOutside = closeOnTapOutside
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view
        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }
    
    public enum PopupType {

        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)

        func shouldBeCentered() -> Bool {
            switch self {
            case .`default`:
                return true
            default:
                return false
            }
        }
    }

    public enum Position {
        case top
        case bottom
    }

    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool
    @Binding var item: Item?

    var sheetPresented: Bool {
        item != nil || isPresented
    }

    var type: PopupType
    var position: Position

    var animation: Animation

    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// Should close on tap outside - default is `true`
    var closeOnTapOutside: Bool
    
    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// is called on any close action
    var dismissCallback: () -> ()

    var view: () -> PopupContent

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    var dispatchWorkHolder = DispatchWorkHolder()

    // MARK: - Private Properties
    
    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero
    @State private var presenterSafeArea: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    /// The rect and safe area of popup content
    @State private var sheetContentRect: CGRect = .zero
    @State private var sheetSafeArea: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGFloat = 0
    
    /// Show content for lazy loading
    @State private var showContent: Bool = false
    
    /// Should present the animated part of popup (sliding background)
    @State private var animatedContentIsPresented: Bool = false
    
    /// The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        switch type {
        case .`default`:
            return -presenterContentRect.midY + screenHeight/2
        case .toast:
            if position == .bottom {
                return presenterContentRect.minY + presenterSafeArea.bottom + presenterContentRect.height - presenterContentRect.midY - sheetContentRect.height/2
            } else {
                return presenterContentRect.minY - presenterSafeArea.top - presenterContentRect.midY + sheetContentRect.height/2
            }
        case .floater(let verticalPadding, let useSafeAreaInset):
            if position == .bottom {
                return presenterContentRect.minY + presenterSafeArea.bottom + presenterContentRect.height - presenterContentRect.midY - sheetContentRect.height/2 - verticalPadding + (useSafeAreaInset ? -presenterSafeArea.bottom : 0)
            } else {
                return presenterContentRect.minY - presenterSafeArea.top - presenterContentRect.midY + sheetContentRect.height/2 + verticalPadding + (useSafeAreaInset ? presenterSafeArea.top : 0)
            }
        }
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if position == .top {
            if presenterContentRect.isEmpty {
                return -1000
            }
            return -presenterContentRect.midY - sheetContentRect.height/2 - 5
        } else {
            if presenterContentRect.isEmpty {
                return 1000
            }
            return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return animatedContentIsPresented ? displayedOffset : hiddenOffset
    }
    
    /// The current background opacity, based on the **presented** property
    private var currentBackgroundOpacity: Double {
        return animatedContentIsPresented ? 1.0 : 0.0
    }

    private var screenSize: CGSize {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
        #else
        return NSScreen.main?.frame.size ?? .zero
        #endif
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        main(content: content)
            .onAppear {
                appearAction(sheetPresented: sheetPresented)
            }
            .valueChanged(value: isPresented) { isPresented in
                appearAction(sheetPresented: isPresented)
            }
            .valueChanged(value: item) { item in
                appearAction(sheetPresented: item != nil)
            }
    }

    private func main(content: Content) -> some View {
        ZStack {
            content
                .frameGetter($presenterContentRect, $presenterSafeArea)

            if showContent {
                popupBackground()
            }
        }
        .overlay(
            Group {
                if showContent {
                    sheet()
                }
            }
        )
    }

    private func popupBackground() -> some View {
        backgroundColor
            .applyIf(closeOnTapOutside) { view in
                view.contentShape(Rectangle())
            }
            .addTapIfNotTV(if: closeOnTapOutside) {
                dismiss()
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(currentBackgroundOpacity)
            .animation(animation)
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {

        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            dispatchWorkHolder.work?.cancel()
            
            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.
			
            let block = dismissCallback
            dispatchWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                block()
            })
            if sheetPresented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }

        let sheet = ZStack {
            self.view()
                .addTapIfNotTV(if: closeOnTap) {
                    dismiss()
                }
                .frameGetter($sheetContentRect, $sheetSafeArea)
                .offset(y: currentOffset)
                .animation(animation)
        }

        #if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet
            .applyIf(dragToDismiss) {
                $0.offset(y: dragOffset())
                    .simultaneousGesture(drag)
            }
        #else
        return sheet
        #endif
    }

    #if !os(tvOS)
    func dragOffset() -> CGFloat {
        if (position == .bottom && dragState.translation.height > 0) ||
           (position == .top && dragState.translation.height < 0) {
            return dragState.translation.height
        }
        return lastDragPosition
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let reference = sheetContentRect.height / 3
        if (position == .bottom && drag.translation.height > reference) ||
            (position == .top && drag.translation.height < -reference) {
            lastDragPosition = drag.translation.height
            withAnimation {
                lastDragPosition = 0
            }
            dismiss()
        }
    }
    #endif
    
    private func appearAction(sheetPresented: Bool) {
        if sheetPresented {
            showContent = true
            DispatchQueue.main.async {
                animatedContentIsPresented = true
            }
        } else {
            animatedContentIsPresented = false
        }
    }
    
    private func dismiss() {
        dispatchWorkHolder.work?.cancel()
        isPresented = false
        item = nil
        dismissCallback()
    }
}

final class DispatchWorkHolder {
    var work: DispatchWorkItem?
}

private final class ClassReference<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}


extension View {

    @ViewBuilder
    fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { value in
                onChange(value)
            }
        }
    }
}

extension View {
    public func frameGetter(_ frame: Binding<CGRect>, _ safeArea: Binding<EdgeInsets>) -> some View {
        modifier(FrameGetter(frame: frame, safeArea: safeArea))
    }
}

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect
    @Binding var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.safeArea = proxy.safeAreaInsets
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}
