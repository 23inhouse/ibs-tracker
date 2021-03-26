//
//  ColoredRowChartStyle.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/3/21.
//

import Charts
import SwiftUI

struct ColoredRowChartStyle<Row: View>: ChartStyle {
  private let row: Row
  private let spacing: CGFloat
  private let colors: [Color]

  init(row: Row, spacing: CGFloat = 8, colors: [Color]) {
    self.row = row
    self.spacing = spacing
    self.colors = colors
  }

  func makeBody(configuration: Self.Configuration) -> some View {
    let data: [ColoredRowData] = configuration.dataMatrix
      .map { $0.reduce(0, +) }
      .reversed()
      .enumerated()
      .map { ColoredRowData(id: $0.offset, data: $0.element) }

    return GeometryReader { geometry in
      self.rowChart(in: geometry, data: data)
    }
  }

  private func rowChart(in geometry: GeometryProxy, data: [ColoredRowData]) -> some View {
    let rowHeight = (geometry.height - (CGFloat(data.count - 1) * spacing)) / CGFloat(data.count)

    return ZStack(alignment: .topLeading) {
      ForEach(data) { element in
        row
          .foregroundColor(colors.intermediate(percentage: element.data * 100))
          .alignmentGuide(.top, computeValue: { _ in topAlignmentGuide(for: element.id, in: geometry.height, dataCount: data.count) })
          .frame(width: rowWidth(data: element.data, in: geometry.width), height: rowHeight)
      }
    }
    .frame(width: geometry.width, height: geometry.height, alignment: .leading)
  }

  private func rowWidth(data: CGFloat, in availableWidth: CGFloat) -> CGFloat {
    availableWidth * data
  }

  private func topAlignmentGuide(for index: Int, in availableHeight: CGFloat, dataCount: Int) -> CGFloat {
    let rowHeight = (availableHeight - (CGFloat(dataCount - 1) * spacing)) / CGFloat(dataCount)
    return (CGFloat(index) * rowHeight) + (CGFloat(index - 1) * spacing)
  }
}

struct ColoredRowData: Identifiable {
  let id: Int
  let data: CGFloat
}

struct DefaultColoredRowView: View {
  public var body: some View {
    Color.blue
  }
}

extension ColoredRowChartStyle where Row == DefaultColoredRowView {
  init(spacing: CGFloat = 8) {
    self.init(row: DefaultColoredRowView(), spacing: spacing, colors: [.blue, .green])
  }
}
