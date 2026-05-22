//
//  ButtonsSwitcher.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 20.05.2026.
//

import SwiftUI

protocol ButtonsEnum: CaseIterable, Sendable, RawRepresentable where RawValue == Int {
    var string: String { get }
}

extension ButtonsEnum {
    var string: String {
        "\(self)".capitalized
    }
}

struct ButtonsSwitcher<Enum: ButtonsEnum>: View {

    @Binding var selection: Enum
    var additionalActionClosure: ()->()

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<Enum.allCases.count, id: \.self) { i in
                Button(Enum.allCases[i as! Enum.AllCases.Index].string) {
                    if let tab = Enum(rawValue: i) {
                        additionalActionClosure()
                        withAnimation {
                            selection = tab
                        }
                    }
                }
                .padding(8, 4)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(selection.rawValue == i ? Color(.skyBlue) : Color(.skyBlue).opacity(0.5))
                }
            }
        }
    }
}
