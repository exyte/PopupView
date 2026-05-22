//
//  PositionExamples.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 20.05.2026.
//

import SwiftUI
import PopupView

enum ModeButtons: Int, ButtonsEnum {
    case window, overlay, sheet

    var popupMode: Popup.DisplayMode {
        switch self {
        case .window: return .window
        case .overlay: return .overlay
        case .sheet: return .sheet
        }
    }
}

enum TypeButtons: Int, ButtonsEnum {
    case `default`, toast, floater, noSafeArea

    var popupType: Popup.PopupType {
        switch self {
        case .default: return .default
        case .toast: return .toast
        case .floater: return .floater()
        case .noSafeArea: return .floater(useSafeAreaInset: false)
        }
    }
}

struct PositionExamplesView: View {
    @State var selectedMode: ModeButtons = .window
    @State var selectedType: TypeButtons = .default

    @State var resetToken = UUID()

    let positions: [Popup.Position] = [.topLeading, .top, .topTrailing, .leading, .center, .trailing, .bottomLeading, .bottom, .bottomTrailing]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ButtonsSwitcher(selection: $selectedMode) { resetToken = UUID() }
                ButtonsSwitcher(selection: $selectedType) { resetToken = UUID() }
                    .padding(.bottom, 50)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(40), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(positions) { position in
                        button(position: position)
                    }
                }
                .padding(.bottom, 50)

                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        Color.clear.frame(width: 40, height: 40)
                        button(appearFrom: .topSlide)
                        Color.clear.frame(width: 40, height: 40)
                    }

                    GridRow {
                        button(appearFrom: .leftSlide)
                        button(appearFrom: .centerScale)
                        button(appearFrom: .rightSlide)
                    }

                    GridRow {
                        Color.clear.frame(width: 40, height: 40)
                        button(appearFrom: .bottomSlide)
                        Color.clear.frame(width: 40, height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color(.lightGrey).ignoresSafeArea())
        .frame(maxWidth: .infinity)
    }

    func button(position: Popup.Position = .center, appearFrom: Popup.AppearAnimation? = nil) -> some View {
        PositionPopupShowingButton(
            displayMode: selectedMode.popupMode,
            type: selectedType.popupType,
            position: position,
            appearFrom: appearFrom,
            resetToken: resetToken
        )
    }
}

struct PositionPopupShowingButton: View {
    var displayMode: Popup.DisplayMode
    var type: Popup.PopupType
    var position: Popup.Position
    var appearFrom: Popup.AppearAnimation?

    var resetToken: UUID

    @State private var show: Bool = false

    var body: some View {
        Button {
            show = true
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .shadow(radius: 2, x: 1, y: 2)
        }
        .onChange(of: resetToken) {
            show = false
        }
        .popup(isPresented: $show) {
            if displayMode == .overlay {
                PositionExamplePopupOverlay()
            } else if type.isToast {
                PositionExamplePopupToast(displayMode: displayMode, type: type, position: position)
            } else {
                PositionExamplePopupBody(displayMode: displayMode, type: type, position: position)
                    .frame(width: 180, height: 180)
            }
        } customize: {
            $0
                .displayMode(displayMode)
                .type(type)
                .position(position)
                .appearFrom(appearFrom)
                .closeOnTapOutside(true)
                .closeOnTap(false)
        }
    }
}

struct PositionExamplePopupOverlay: View {
    var body: some View {
        Color(.skyBlue).frame(width: 10, height: 10)
            .cornerRadius(2)
    }
}

struct PositionExamplePopupToast: View {
    var displayMode: Popup.DisplayMode
    var type: Popup.PopupType
    var position: Popup.Position

    var body: some View {
        let view = PositionExamplePopupBody(displayMode: displayMode, type: type, position: position)

        switch position {
        case .top, .bottom:
            view.frame(maxWidth: .infinity).frame(height: 180)
        case .leading, .trailing:
            view.frame(maxHeight: .infinity).frame(width: 180)
        default:
            view.frame(width: 180, height: 180)
        }
    }
}

struct PositionExamplePopupBody: View {
    var displayMode: Popup.DisplayMode
    var type: Popup.PopupType
    var position: Popup.Position

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            Color(.skyBlue)
                                .overlay {
                                    Rectangle()
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                }
                        }
                    }
                }
            }

            VStack {
                Text(String(describing: displayMode).capitalized)
                    .font(.system(size: 20))
                Text("type: \(String(describing: type).capitalized)")
                Text("position: \(String(describing: position).capitalized)")
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding()
        }
    }
}

extension Popup.Position: @retroactive Identifiable {
    public var id: String {
        String(describing: self)
    }
}
