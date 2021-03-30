//
//  SymptomsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/3/21.
//

import SwiftUI

struct GraphScore {
  var timestamp: Date
  var value: Double
}

struct SymptomsView: View {
  @EnvironmentObject private var appState: IBSData

  @State private var include: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  @State private var graphScale: CGFloat = 1
  @State private var lastGraphScale: CGFloat = 1
  @State private var graphOffset: CGFloat = 0
  @State private var lastGraphOffset: CGFloat = 0
  @State private var graphHeight: CGFloat = 0
  @State private var lastRecordInterval: Double = 0
  @State private var timestamps: [Date] = []
  @State private var filteredScores: [GraphScore] = []

  private let numberOfColumns = 24
  private let barsPerColumn = 4

  private let horizontalAxisHeight: CGFloat = 5
  private let horizontalAxisWidth: CGFloat = 100
  private let verticalAxisHeight: CGFloat = 10
  private let verticalAxisWidth: CGFloat = 45

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

  var body: some View {
    VStack {
      HStack(spacing: 2) {
        cornerSpacer
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
    SymptomsControlsView(include: $include, resetAction: {
      graphSetting(reset: true)
    })
    .onChange(of: include) { _ in
      filteredScores = filterScores()
    }
  }

  private var chart: some View {
    GeometryReader { geometry in
      SymptomsGraphView(timestamps: $timestamps, filteredScores: $filteredScores, barsPerColumn: barsPerColumn, numberOfColumns: numberOfColumns)
        .onAppear {
          timestamps = calcTimestamps()
          graphSetting(height: geometry.height)
      }
    }
  }

  private var horizontalAxis: some View {
    HStack {
      ForEach(Scales.validCases, id: \.self) { scale in
        Text(scale.label())
          .fontWeight(.bold)
          .font(Font.system(size: 8))
          .foregroundColor(ColorCodedContent.scaleColor(for: scale))
          .frame(height: horizontalAxisHeight)
          .frame(maxWidth: .infinity)
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: horizontalAxisHeight)
    .padding(.horizontal, 1)
  }

  private var verticalAxis: some View {
    SymptomsVerticalAxisView(timestamps: $timestamps, verticalAxisWidth: verticalAxisWidth, numberOfColumns: numberOfColumns)
  }

  private var cornerSpacer: some View {
    Rectangle()
      .foregroundColor(.clear)
      .frame(width: verticalAxisWidth, height: horizontalAxisHeight)
  }
}

private extension SymptomsView {
  func filterScores() -> [GraphScore] {
    return appState.records.compactMap { record in
      var score = Double(record.graphScore(include: include))
      if score > 4 { score = 4 }

      return score >= 0 ? GraphScore(timestamp: record.timestamp, value: score) : nil
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
}

struct SymptomsView_Previews: PreviewProvider {
  static var previews: some View {
    SymptomsView()
      .environmentObject(IBSData())
  }
}
