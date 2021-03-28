//
//  SymptomsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/3/21.
//

import Charts
import Shapes
import SwiftUI

struct Score {
  var timestamp: Date
  var value: Int
}

struct SymptomsView: View {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject private var appState: IBSData

  @State private var include: [ItemType] = [.bm, .gut, .ache, .mood, .skin] {
    didSet {
      filteredScores = filterScores()
    }
  }
  @State var graphScale: CGFloat = 1
  @State var lastGraphScale: CGFloat = 1
  @State var graphOffset: CGFloat = 0
  @State var lastGraphOffset: CGFloat = 0
  @State var graphHeight: CGFloat = 0
  @State var lastRecordInterval: Double = 0
  @State var timestamps: [Date] = []
  @State var filteredScores: [Score] = []

  private let options: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  private let strokeStyle = StrokeStyle(lineWidth: 1.0, lineJoin: .round)

  private let numberOfColumns = 24
  private let barsPerColumn = 4

  private let horizontalAxisHeight: CGFloat = 5
  private let horizontalAxisWidth: CGFloat = 100
  private let verticalAxisHeight: CGFloat = 10
  private let verticalAxisWidth: CGFloat = 45

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  private var recordCount: Int {
    appState.records.count
  }

  private var firstRecord: IBSRecord {
    appState.records.first ?? IBSRecord(note: "", timestamp: Date().nearest(5, .minute))
  }

  private var lastRecord: IBSRecord {
    appState.records.last ?? IBSRecord(note: "", timestamp: Date().nearest(5, .minute))
  }

  private var recordInterval: TimeInterval {
    let firstDate = firstRecord.timestamp
    let lastDate = lastRecord.timestamp
    return lastDate.timeIntervalSince(firstDate)
  }

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

    let firstTimestampBeforeScore: (Score) -> Bool = { firstTimestamp <= $0.timestamp }
    guard var scoreIndex = filteredScores.firstIndex(where: firstTimestampBeforeScore) else { return [] }

    return timestampsPerBar.map { endTimestamp in
      guard scoreIndex < filteredScores.count else { return 0 }

      var score: Score = filteredScores[scoreIndex]
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

  private var dateFormat: String {
    let count = timestamps.count
    guard count > 1 else { return "MMM dd" }

    let first = timestamps.first!
    let last = timestamps.last!
    let interaval = Int(last.timeIntervalSince(first))

    let oneDayPerColumn = (numberOfColumns - 1) * 24 * 60 * 60
    let daysToSplit = oneDayPerColumn / 2
    return interaval > daysToSplit ? "MMM dd" : "MMM dd\nHH:mm"
  }

  private var dateFormatDifference: String {
    return dateFormat == "MMM dd" ? "MMM" : "dd"
  }

  var body: some View {
    VStack {
      HStack(spacing: 2) {
        Rectangle().foregroundColor(.clear).frame(width: verticalAxisWidth, height: horizontalAxisHeight)
        horizontalAxis
      }
      HStack(spacing: 2) {
        verticalAxis
        chart
      }
      .layoutPriority(1)
    }
    .padding(5)
    .overlay(controls, alignment: .bottomTrailing)
    .gesture(magnificationGesture)
    .simultaneousGesture(dragGesture)
    .onAppear {
      filteredScores = filterScores()
    }
  }

  private var magnificationGesture: _EndedGesture<_ChangedGesture<MagnificationGesture>> {
    MagnificationGesture()
      .onChanged { scale in
        let calculatedScale = lastGraphScale * scale
        guard let newScale = calcNew(scale: calculatedScale) else { return }
        graphScale = newScale
        timestamps = calcTimestamps()
      }
      .onEnded { _ in
        guard let newScale = calcNew(scale: graphScale) else { return }
        graphScale = newScale
        timestamps = calcTimestamps()

        lastGraphScale = graphScale
      }
  }

  private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
    DragGesture()
      .onChanged { gesture in
        let offset = gesture.translation.y
        guard let newGraphOffset = calcNew(offset: offset) else { return }
        graphOffset = newGraphOffset
        timestamps = calcTimestamps()
      }
      .onEnded { _ in lastGraphOffset = graphOffset }
  }

  private var controls: some View {
    VStack {
      ForEach(options, id: \.self) { itemType in
        TypeShape(type: itemType)
          .stroke(style: strokeStyle)
          .scaledToFit()
          .rotate(.degrees(90))
          .frame(25)
          .foregroundColor(include.contains(itemType) ? .blue : .secondary)
          .backgroundColor(backgroundColor)
          .padding(.vertical, 5)
          .padding(.horizontal, 2)
          .onTapGesture {
            include.toggle(on: !include.contains(itemType), element: itemType)
          }
      }
      Button(action: { graphSetting(reset: true) }) {
        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.secondary, lineWidth: 0.5)
        .backgroundColor(backgroundColor)
        .cornerRadius(20)
    )
    .padding(.horizontal, 10)
    .padding(.vertical, 35)
  }

  private var chart: some View {
    GeometryReader { geometry in
      GraphView(timestamps: $timestamps, data: data)
        .onAppear {
          timestamps = calcTimestamps()
          graphSetting(height: geometry.height)
      }
    }
  }

  private var horizontalAxis: some View {
    AxisLabels(.horizontal, data: Scales.validCases, id: \.self) { scale in
      Text(scale.label())
        .fontWeight(.bold)
        .font(Font.system(size: 8))
        .foregroundColor(ColorCodedContent.scaleColor(for: scale))
        .frame(width: horizontalAxisWidth, height: horizontalAxisHeight)
    }
    .frame(height: horizontalAxisHeight)
    .padding(.horizontal, 1)
  }

  private var verticalAxis: some View {
      VStack {
        ForEach(Array(timestamps.enumerated()), id: \.element) { i, date in
          Text(date.string(for: isDifferentDate(for: i) ? firstPart(of: dateFormat) : lastPart(of: dateFormat)))
            .font(Font.system(size: 8))
            .foregroundColor(isDifferentDate(for: i) ? .primary : .secondary)
            .align(.trailing)
            .frame(width: verticalAxisWidth)
            .frame(maxHeight: .infinity)
        }
      }
      .padding(.vertical, -10.5)
  }
}

private extension SymptomsView {
  func filterScores() -> [Score] {
    return appState.records.compactMap { record in
      let score = record.graphScore(include: include)
      return score >= 0 ? Score(timestamp: record.timestamp, value: score) : nil
    }
  }

  func graphSetting(reset: Bool = false, height: CGFloat? = nil) {
    if reset || recordInterval != lastRecordInterval {
      graphScale = 1
      lastGraphScale = 1
      graphOffset = 0
      lastGraphOffset = 0
      lastRecordInterval = recordInterval
    }

    timestamps = calcTimestamps()

    guard let height = height else { return }
    graphHeight = height
  }

  func calcTimestamps() -> [Date] {
    var firstScaledDate: Date
    var scaledInterval: Double

    let (expandedFirstDate, expandedLastDate) = calcExpandedTimestamps(firstRecord.timestamp, lastRecord.timestamp)
    let expandedInterval = expandedLastDate.timeIntervalSince(expandedFirstDate)
    let offsetDate = expandedFirstDate.addingTimeInterval(expandedInterval / 2)

    scaledInterval = expandedInterval / Double(graphScale)
    let scaledOffsetDate = offsetDate.addingTimeInterval(TimeInterval(graphOffset))

    firstScaledDate = scaledOffsetDate.addingTimeInterval(-scaledInterval / 2)

    let chunkedInterval = scaledInterval / TimeInterval(numberOfColumns)
    return (0 ... numberOfColumns).map { i in
      firstScaledDate.addingTimeInterval(chunkedInterval * Double(i))
    }
  }

  func isDifferentDate(for index: Int) -> Bool {
    guard index > 0 else { return true }
    guard index < timestamps.count - 1 else { return true }
    return timestamps[index - 1].string(for: dateFormatDifference) != timestamps[index].string(for: dateFormatDifference)
  }

  func firstPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).dropLast().joined(separator: " "))
  }

  func lastPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).last!)
  }

  func calcNew(scale: CGFloat) -> CGFloat? {
    let calculatedScale = scale

    let firstTimestamp = timestamps.first!
    let lastTimestamp = timestamps.last!
    let interval = lastTimestamp.timeIntervalSince(firstTimestamp)

    let (expandedFirstDate, expandedLastDate) = calcExpandedTimestamps(firstTimestamp, lastTimestamp)
    var expandedInterval = expandedLastDate.timeIntervalSince(expandedFirstDate)

    let fiveMinutes = 5 * 60
    let minimumInterval = Double(numberOfColumns * fiveMinutes)
    if expandedInterval < minimumInterval {
      expandedInterval = minimumInterval
      return nil
    }

    let adjustedFactor = interval / expandedInterval
    let newScale = calculatedScale * CGFloat(adjustedFactor)

    return newScale
  }

  func calcNew(offset: CGFloat) -> CGFloat? {
    guard graphHeight > 0 else { return nil }

    let firstTimestamp = timestamps.first!
    let lastTimestamp = timestamps.last!
    let interval = CGFloat(lastTimestamp.timeIntervalSince(firstTimestamp))
    let intervalPerBar = interval / CGFloat(numberOfColumns * barsPerColumn)

    let adjustment = offset / graphHeight
    let intervalOffset = ceil(interval * adjustment / intervalPerBar) * intervalPerBar

    let newGraphOffset = lastGraphOffset - CGFloat(intervalOffset)

    return newGraphOffset
  }

  func calcExpandedTimestamps(_ firstTimestamp: Date, _ lastTimestamp: Date) -> (Date, Date) {
    var interval = lastTimestamp.timeIntervalSince(firstTimestamp)
    if interval < 1 { interval = 1 }
    let numberOfBars = Double(numberOfColumns * barsPerColumn)
    let roundingFactor = 5 * 60 * numberOfBars
    let roundedInterval = ceil(interval / roundingFactor) * roundingFactor

    let expandedLastDate = lastTimestamp.addingTimeInterval(0)
    let expandedFirstDate = expandedLastDate.addingTimeInterval(-roundedInterval)

    return (expandedFirstDate, expandedLastDate)
  }
}

struct SymptomsView_Previews: PreviewProvider {
  static var previews: some View {
    SymptomsView()
      .environmentObject(IBSData())
  }
}


struct GraphView: View {
  @Binding var timestamps: [Date]
  var data: [CGFloat]

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
