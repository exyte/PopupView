//
//  PopupsList.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

struct FloatsStateBig {
    var showingTopLeading = false
    var showingTop = false
    var showingTopTrailing = false
    
    var showingLeading = false
    // center is a regular popup
    var showingTrailing = false
    
    var showingBottomLeading = false
    var showingBottom = false
    var showingBottomTrailing = false
}

struct FloatsStateSmall {
    var showingTopFirst = false
    var showingTopSecond = false
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct ToastsState {
    var showingTopFirst = false
    var showingTopSecond = false
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct PopupsState {
    var middleItem: SomeItem?
    var showingBottomFirst = false
    var showingBottomSecond = false
}

struct ActionSheetsState {
    var showingFirst = false
    var showingSecond = false
}

struct InputSheetsState {
    var showingFirst = false
    var showingScroll = false
}

struct SectionHeader: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct PopupTypesButtonsList: View {
    @Binding var floatsBig: FloatsStateBig
    @Binding var floatsSmall: FloatsStateSmall
    @Binding var toasts: ToastsState
    @Binding var popups: PopupsState
    @Binding var actionSheets: ActionSheetsState
    @Binding var inputSheets: InputSheetsState
    
    let hideAll: () -> ()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                safeSpaceForMac()
                
                Group {
                    SectionHeader(name: "Floats")
                        .padding(.bottom, 12)
                    
                    floatsSection()
                }
                
                Group {
                    SectionHeader(name: "Toasts")
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                    
                    toastsSection()
                }
                
                Group {
                    SectionHeader(name: "Popups")
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                    
                    popupsSection()
                }
                
#if os(iOS)
                Group {
                    SectionHeader(name: "Action sheets")
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                    
                    actionSheetsSection()
                }
#endif
                
                Group {
                    SectionHeader(name: "Inputs")
                        .padding(.bottom, 12)
                    
                    inputsSection()
                }
                
                safeSpaceForMac()
            }
        }
        .padding(.top, 1)
        .background(Color(.lightGrey).ignoresSafeArea())
    }
    
    func typeIconButton<V: View>(isShowing: Binding<Bool>, title: String, detail: String = "", icon: () -> V) -> some View {
        Button {
            hideAll()
            isShowing.wrappedValue.toggle()
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                
                HStack {
                    icon()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Text(detail)
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .opacity(0.4)
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal, 20)
#if os(tvOS)
        .buttonStyle(.automatic)
#else
        .customButtonStyle(foreground: .black, background: .clear)
#endif
    }
    
    func safeSpaceForMac() -> some View {
#if os(macOS)
        Color.clear.padding(.bottom, 40)
#else
        EmptyView()
#endif
    }
    
    @MainActor @ViewBuilder
    func floatsSection() -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            floatsSectionSmall()
        } else {
            floatsSectionBig()
        }
#else
        floatsSectionBig()
#endif
    }
    
    @ViewBuilder
    func floatsSectionSmall() -> some View {
        Button("Show multiple popups") {
            popups.showingBottomFirst = true
            toasts.showingBottomSecond = true
            floatsSmall.showingBottomFirst = true
            floatsSmall.showingTopSecond = true
            toasts.showingTopSecond = true
        }
        
        typeIconButton(
            isShowing: $floatsSmall.showingTopFirst,
            title: "Top version 1",
            detail: "Top float with a picture and one button"
        ) {
            SmallFloatsIcon(alignment: .top)
        }
        
        typeIconButton(
            isShowing: $floatsSmall.showingTopSecond,
            title: "Top version 2",
            detail: "Top float with a picture"
        ) {
            SmallFloatsIcon(alignment: .top)
        }
        
        typeIconButton(
            isShowing: $floatsSmall.showingTopFirst,
            title: "Bottom version 1",
            detail: "Bottom float with a picture"
        ) {
            SmallFloatsIcon(alignment: .bottom)
        }
        
        typeIconButton(
            isShowing: $floatsSmall.showingTopSecond,
            title: "Bottom version 2",
            detail: "Bottom float with a picture"
        ) {
            SmallFloatsIcon(alignment: .bottom)
        }
    }
    
    @ViewBuilder
    func floatsSectionBig() -> some View {
        typeIconButton(
            isShowing: $floatsBig.showingTopLeading,
            title: "Top Leading"
        ) {
            BigFloatsIcon(alignment: .topLeading)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingTop,
            title: "Top Center"
        ) {
            BigFloatsIcon(alignment: .top)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingTopTrailing,
            title: "Top Trailing"
        ) {
            BigFloatsIcon(alignment: .topTrailing)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingLeading,
            title: "Center Leading"
        ) {
            BigFloatsIcon(alignment: .leading)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingTrailing,
            title: "Center Trailing"
        ) {
            BigFloatsIcon(alignment: .trailing)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingBottomLeading,
            title: "Bottom Leading"
        ) {
            BigFloatsIcon(alignment: .bottomLeading)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingBottom,
            title: "Bottom Center"
        ) {
            BigFloatsIcon(alignment: .bottom)
        }
        
        typeIconButton(
            isShowing: $floatsBig.showingBottomTrailing,
            title: "Bottom Trailing"
        ) {
            BigFloatsIcon(alignment: .bottomTrailing)
        }
    }
    
    @ViewBuilder
    func toastsSection() -> some View {
        typeIconButton(
            isShowing: $toasts.showingTopFirst,
            title: "Top version 1",
            detail: "Top toast only text"
        ) {
            ToastIcon(position: .top)
        }
        
        typeIconButton(
            isShowing: $toasts.showingTopSecond,
            title: "Top version 2",
            detail: "Top float with picture"
        ) {
            ToastIcon(position: .top)
        }
        
        typeIconButton(
            isShowing: $toasts.showingBottomFirst,
            title: "Bottom version 1",
            detail: "Bottom float with a picture and two buttons"
        ) {
            ToastIcon(position: .bottom)
        }
        
        typeIconButton(
            isShowing: $toasts.showingBottomSecond,
            title: "Bottom version 2",
            detail: "Bottom float with a picture"
        ) {
            ToastIcon(position: .bottom)
        }
    }
    
    @ViewBuilder
    func popupsSection() -> some View {
        //        ItemPopupButton(item: $popups.middleItem, hideAll: hideAll) { todoalisa
        //            PopupTypeIconButton(
        //                title: "Middle",
        //                detail: "Popup in the middle of the screen with a picture"
        //            ) {
        //                PopupIcon(style: .default)
        //            }
        //        }
        
        typeIconButton(
            isShowing: $popups.showingBottomFirst,
            title: "Bottom version 1",
            detail: "Popup bottom"
        ) {
            PopupIcon(style: .bottomFirst)
        }
        
        typeIconButton(
            isShowing: $popups.showingBottomSecond,
            title: "Bottom version 2",
            detail: "Popup bottom"
        ) {
            PopupIcon(style: .bottomSecond)
        }
    }
    
    @ViewBuilder
    func actionSheetsSection() -> some View {
        typeIconButton(
            isShowing: $actionSheets.showingFirst,
            title: "Version 1",
            detail: "Action sheets"
        ) {
            ActionSheetIcon()
        }
        
        typeIconButton(
            isShowing: $actionSheets.showingSecond,
            title: "Version 2",
            detail: "Action sheets"
        ) {
            ActionSheetIcon()
        }
    }
    
    @ViewBuilder
    func inputsSection() -> some View {
        typeIconButton(
            isShowing: $inputSheets.showingFirst,
            title: "Bottom Input",
            detail: "Popup in the bottom of the screen with an input text field"
        ) {
            InputSheetIcon()
        }
        
#if os(iOS)
        typeIconButton(
            isShowing: $inputSheets.showingScroll,
            title: "Scroll + Keyboard (issue #281)",
            detail: "Scroll popup with TextField - popup should stay at bottom"
        ) {
            InputSheetIcon()
        }
#endif
    }
}

//struct PopupsList_Previews: PreviewProvider { todoalisa
//    static var previews: some View {
//        PopupButton(
//            isShowing: Binding<Bool>.init(get: { true },
//                                          set: { _ in }),
//            hideAll: {})
//        {
//            PopupTypeIconButton(
//                title: "Top version 1",
//                detail: "Top float with a picture and one button"
//            ) {
//                BigFloatsIcon(alignment: .top)
//            }
//        }
//    }
//}
