//
//  ButtonsMatrix.swift
//  PopupExample
//
//  Created by Alisa Mylnikova on 29.05.2026.
//

import SwiftUI

struct ButtonsMatrix<LeftValue: Hashable, TopValue: Hashable, Cell: View>: View {

    let leftAxisTitle: String
    let leftAxisValues: [LeftValue]

    let topAxisTitle: String
    let topAxisValues: [TopValue]

    @ViewBuilder let cellBuilder: (LeftValue, TopValue) -> Cell

    @State private var cellSize: CGSize = .zero
    @State private var availableFrame: CGRect = .zero
    @State private var axisFrame: CGRect = .zero

    var body: some View {
        VStack(spacing: 10) {
            // top row
            HStack(spacing: 10) {
                Color.clear.frame(width: axisFrame.height)

                axisView(topAxisTitle, topAxisValues)
                    .frameGetter($axisFrame)
            }
            .fixedSize()

            // main row
            HStack(spacing: 10) {
                axisView(leftAxisTitle, leftAxisValues.reversed()) // -90 rotation turns them over
                    .fixedSize()
                    .frame(width: axisFrame.height, height: cellSize.width * 2)
                    .rotationEffect(.degrees(-90))

                tableView
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frameGetter($availableFrame)
        .onChange(of: availableFrame) {
            let count = CGFloat(topAxisValues.count)
            let cellWidth = (availableFrame.width - axisFrame.height - 10) / count
            cellSize = CGSizeMake(cellWidth, cellWidth)
        }
    }

    func axisView<Value: Hashable>(_ title: String, _ values: [Value]) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(values, id: \.self) { value in
                    Text(String(describing: value))
                        .frame(width: cellSize.width)
                }
            }
        }
    }

    private var tableView: some View {
        ZStack {
            Rectangle()
                .stroke(.gray, lineWidth: 1)

            VStack(spacing: 0) {
                ForEach(0..<leftAxisValues.count - 1, id: \.self) { _ in
                    Spacer()
                    Rectangle().fill(.gray).frame(height: 1)
                    Spacer()
                }
            }

            HStack(spacing: 0) {
                ForEach(0..<topAxisValues.count - 1, id: \.self) { _ in
                    Spacer()
                    Rectangle().fill(.gray).frame(width: 1)
                    Spacer()
                }
            }

            VStack(spacing: 0) {
                ForEach(leftAxisValues, id: \.self) { leftValue in
                    HStack(spacing: 0) {
                        ForEach(topAxisValues, id: \.self) { topValue in
                            cellBuilder(leftValue, topValue)
                                .frame(width: cellSize.width, height: cellSize.height)
                        }
                    }
                }
            }
        }
    }
}
