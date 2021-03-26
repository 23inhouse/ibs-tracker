//
//  ColoredColumnChartStyle.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/3/21.
//

import Charts
import SwiftUI

struct ColoredColumnChartStyle<Column: View>: ChartStyle {
  private let column: Column
  private let spacing: CGFloat
  private let colors: [Color]

  init(column: Column, spacing: CGFloat = 8, colors: [Color]) {
    self.column = column
    self.spacing = spacing
    self.colors = colors
  }

  func makeBody(configuration: Self.Configuration) -> some View {
    let data: [ColoredColumnData] = configuration.dataMatrix
      .map { $0.reduce(0, +) }
      .reversed()
      .enumerated()
      .map { ColoredColumnData(id: $0.offset, data: $0.element) }

    return GeometryReader { geometry in
      self.columnChart(in: geometry, data: data)
    }
  }

  private func columnChart(in geometry: GeometryProxy, data: [ColoredColumnData]) -> some View {
    let columnWidth = (geometry.width - (CGFloat(data.count - 1) * spacing)) / CGFloat(data.count)

    return ZStack(alignment: .bottomLeading) {
      ForEach(data) { element in
        self.column
          .foregroundColor(colors.intermediate(percentage: element.data * 100))
          .alignmentGuide(.leading, computeValue: { _ in leadingAlignmentGuide(for: element.id, in: geometry.width, dataCount: data.count) })
          .alignmentGuide(.bottom, computeValue: { _ in columnHeight(data: element.data, in: geometry.height) })
          .frame(width: columnWidth, height: columnHeight(data: element.data, in: geometry.height))
      }
    }
    .frame(width: geometry.width, height: geometry.height, alignment: .bottom)
  }

  private func columnHeight(data: CGFloat, in availableHeight: CGFloat) -> CGFloat {
    availableHeight * data
  }

  private func leadingAlignmentGuide(for index: Int, in availableWidth: CGFloat, dataCount: Int) -> CGFloat {
    let columnWidth = (availableWidth - (CGFloat(dataCount - 1) * spacing)) / CGFloat(dataCount)
    return (CGFloat(index) * columnWidth) + (CGFloat(index - 1) * spacing)
  }
}

struct ColoredColumnData: Identifiable {
  let id: Int
  let data: CGFloat
}

struct DefaultColoredColumnView: View {
  public var body: some View {
    Color.blue
  }
}

extension ColoredColumnChartStyle where Column == DefaultColoredColumnView {
  init(spacing: CGFloat = 8) {
    self.init(column: DefaultColoredColumnView(), spacing: spacing, colors: [.blue, .green])
  }
}
