//
//  SymptomsGraphView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 29/3/21.
//

import Charts
import Shapes
import SwiftUI

struct SymptomsGraphView: View {
  @Binding var timestamps: [Date]
  @Binding var filteredScores: [GraphScore]

  var barsPerColumn: Int
  var numberOfColumns: Int

  private var data: [CGFloat] {
    let minumumValue: CGFloat = 0.1

    guard timestamps.count > 0 else { return [] }
    guard filteredScores.count > 0 else { return [] }

    let firstTimestamp = timestamps.first!
    let lastTimestamp = timestamps.last!
    let interval = lastTimestamp.timeIntervalSince(firstTimestamp)
    let numberOfBars = barsPerColumn * numberOfColumns
    let intervalPerBar = interval / TimeInterval(numberOfBars)
    let timestampsPerBar = (1 ... numberOfBars).map { i in
      firstTimestamp.addingTimeInterval(intervalPerBar * Double(i))
    }

    let firstTimestampBeforeScore: (GraphScore) -> Bool = { firstTimestamp <= $0.timestamp }
    guard var scoreIndex = filteredScores.firstIndex(where: firstTimestampBeforeScore) else { return [] }

    return timestampsPerBar.map { endTimestamp in
      guard scoreIndex < filteredScores.count else { return 0 }

      var score: GraphScore = filteredScores[scoreIndex]
      var timestamp: Date = score.timestamp
      var value: CGFloat

      var averageScore: CGFloat = 0
      var averageCount: CGFloat = 0

      while timestamp <= endTimestamp {
        value = CGFloat(score.value)

        averageScore += value
        averageCount += 1
        scoreIndex += 1

        guard scoreIndex < filteredScores.count else { break }

        score = filteredScores[scoreIndex]
        timestamp = score.timestamp
      }

      guard averageCount > 0 else { return 0 }

      var average = averageScore / averageCount
      if average <= minumumValue { average = minumumValue }
      if average > 4 { average = 4 }
      return average * 0.25
    }
  }

  private var coloredRowChartStyle: ColoredRowChartStyle<Capsule> {
    ColoredRowChartStyle(row: Capsule(), spacing: 1, colors: ColorCodedContent.rankedColors.reversed())
  }

  var body: some View {
    Chart(data: data)
      .chartStyle(coloredRowChartStyle)
      .padding(0.5)
      .background(chartGrid)
  }

  private var chartGrid: some View {
    GridPattern(horizontalLines: timestamps.count, verticalLines: Scales.validCases.count + 1)
      .inset(by: 0)
      .stroke(Color.secondary.opacity(0.5), style: .init(lineWidth: 1, lineCap: .round))
  }
}

struct SymptomsGraphView_Previews: PreviewProvider {
  static let timestamp = Date().nearest(5, .minute)
  static let timestamps = Binding.constant([timestamp, timestamp])
  static let filteredScores = Binding.constant([GraphScore(timestamp: timestamp, value: 3)])
  static var previews: some View {
    SymptomsGraphView(timestamps: timestamps, filteredScores: filteredScores, barsPerColumn: 4, numberOfColumns: 24)
  }
}
