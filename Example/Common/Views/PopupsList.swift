//
//  PopupsList.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

private struct SectionHeader: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(0.8)
                
                Text("types")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct PopupTypeView<Content> : View where Content : View {
    let title: String
    let detail: String
    @ViewBuilder let icon: () -> Content
    
    var body: some View {
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
        .padding(.horizontal, 20)
    }
}

struct PopupsList: View {
    @Binding var showingTopFirstFloat: Bool
    @Binding var showingTopSecondFloat: Bool
    @Binding var showingBottomFirstFloat: Bool
    @Binding var showingBottomSecondFloat: Bool
    
    @Binding var showingTopFirstToast: Bool
    @Binding var showingTopSecondToast: Bool
    @Binding var showingBottomFirstToast: Bool
    @Binding var showingBottomSecondToast: Bool
    
    @Binding var showingMiddlePopup: Bool
    @Binding var showingBottomFirstPopup: Bool
    @Binding var showingBottomSecondPopup: Bool
    
#if os(iOS)
    @Binding var showingFirstActionSheet: Bool
    @Binding var showingSecondActionSheet: Bool
#endif
    
    var body: some View {
        let hideAll: () -> () = {
            self.showingTopFirstFloat = false
            self.showingTopSecondFloat = false
            self.showingBottomFirstFloat = false
            self.showingBottomSecondFloat = false
            
            self.showingTopFirstToast = false
            self.showingTopSecondToast = false
            self.showingBottomFirstToast = false
            self.showingBottomSecondToast = false
            
            self.showingMiddlePopup = false
            self.showingBottomFirstPopup = false
            self.showingBottomSecondPopup = false
            
#if os(iOS)
            self.showingFirstActionSheet = false
            self.showingSecondActionSheet = false
#endif
        }
        
        return ZStack {
            Rectangle()
                .fill(Color(hex: "F7F7F9"))
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 12) {
#if os(macOS)
                    Color.clear.padding(.bottom, 40)
#endif
                    Group {
                        SectionHeader(name: "Floats", count: 4)
                            .padding(.bottom, 12)
                        
                        PopupButton(isShowing: $showingTopFirstFloat, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Top version 1",
                                detail: "Top float with a picture and one button"
                            ) {
                                FloatsImage(position: .top)
                            }
                        }
                        PopupButton(isShowing: $showingTopSecondFloat, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Top version 2",
                                detail: "Top float with a picture"
                            ) {
                                FloatsImage(position: .top)
                            }
                        }
                        PopupButton(isShowing: $showingBottomFirstFloat, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 1",
                                detail: "Bottom float with a picture"
                            ) {
                                FloatsImage(position: .bottom)
                            }
                        }
                        PopupButton(isShowing: $showingBottomSecondFloat, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 2",
                                detail: "Bottom float with a picture"
                            ) {
                                FloatsImage(position: .bottom)
                            }
                        }
                    }
                    
                    Group {
                        SectionHeader(name: "Toasts", count: 4)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                        
                        PopupButton(isShowing: $showingTopFirstToast, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Top version 1",
                                detail: "Top toast only text"
                            ) {
                                ToastImage(position: .top)
                            }
                        }
                        PopupButton(isShowing: $showingTopSecondToast, hideAll: hideAll) {
                            PopupTypeView(
                            title: "Top version 2",
                            detail: "Top float with picture"
                        ) {
                            ToastImage(position: .top)
                        }
                        }
                        PopupButton(isShowing: $showingBottomFirstToast, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 1",
                                detail: "Bottom float with a picture and two buttons"
                            ) {
                                ToastImage(position: .bottom)
                            }
                        }
                        PopupButton(isShowing: $showingBottomSecondToast, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 2",
                                detail: "Bottom float with a picture"
                            ) {
                                ToastImage(position: .bottom)
                            }
                        }
                    }
                    
                    Group {
                        SectionHeader(name: "Popups", count: 3)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                        
                        PopupButton(isShowing: $showingMiddlePopup, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Middle",
                                detail: "Popup in the middle of the screen with a picture"
                            ) {
                                PopupImage(style: .default)
                            }
                        }
                        PopupButton(isShowing: $showingBottomFirstPopup, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 1",
                                detail: "Popup bottom"
                            ) {
                                PopupImage(style: .bottomFirst)
                            }
                        }
                        PopupButton(isShowing: $showingBottomSecondPopup, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Bottom version 2",
                                detail: "Popup bottom"
                            ) {
                                PopupImage(style: .bottomSecond)
                            }
                        }
                    }
                    
#if os(iOS)
                    Group {
                        SectionHeader(name: "Action sheets", count: 2)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 12, trailing: 0))
                        
                        PopupButton(isShowing: $showingFirstActionSheet, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Version 1",
                                detail: "Action sheets"
                            ) {
                                ActionSheetImage()
                            }
                        }
                        PopupButton(isShowing: $showingSecondActionSheet, hideAll: hideAll) {
                            PopupTypeView(
                                title: "Version 2",
                                detail: "Action sheets"
                            ) {
                                ActionSheetImage()
                            }
                        }
                    }
#endif
#if os(macOS)
                    Color.clear.padding(.bottom, 40)
#endif
                }
            }
            .padding(.top, 1)
        }
    }
}


struct PopupsList_Previews: PreviewProvider {
    static var previews: some View {
        PopupButton(
            isShowing: Binding<Bool>.init(get: { true },
                                        set: { _ in }),
            hideAll: {})
        {
            PopupTypeView(
                title: "Top version 1",
                detail: "Top float with a picture and one button"
            ) {
                FloatsImage(position: .top)
            }
        }
    }
}
