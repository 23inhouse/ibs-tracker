//
//  SymptomsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/3/21.
//

import Charts
import Shapes
import SwiftUI


struct SymptomsView: View {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject private var appState: IBSData

  @State private var include: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  @State var graphScale: CGFloat = 1
  @State var lastGraphScale: CGFloat = 1
  @State var graphOffset: CGFloat = 0
  @State var lastGraphOffset: CGFloat = 0
  @State var graphHeight: CGFloat = 0
  @State var lastRecordInterval: Double = 0
  @State var timestamps: [Date] = []

  private let options: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  private let strokeStyle = StrokeStyle(lineWidth: 1.0, lineJoin: .round)

  private let numberOfColumns = 24
  private let barsPerColumn = 4

  private let horizontalAxisHeight: CGFloat = 5
  private let horizontalAxisWidth: CGFloat = 100
  private let verticalAxisHeight: CGFloat = 20
  private let verticalAxisWidth: CGFloat = 30

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  private var recordCount: Int {
    appState.records.count
  }

  private var firstRecord: IBSRecord? {
    appState.records.first ?? IBSRecord(note: "", timestamp: Date())
  }

  private var lastRecord: IBSRecord? {
    appState.records.last ?? IBSRecord(note: "", timestamp: Date())
  }

  private var recordInterval: TimeInterval {
    let firstDate = firstRecord!.timestamp
    let lastDate = lastRecord!.timestamp
    return lastDate.timeIntervalSince(firstDate)
  }

  private var records: [IBSRecord] {
    guard recordCount > 1 else { return appState.records }

    let firstTimestamp = timestamps.first!
    let lastTimestamp = timestamps.last!
    return appState.records.filter { record in
      record.timestamp >= firstTimestamp && record.timestamp < lastTimestamp
    }
  }

  private var data: [CGFloat] {
    let minumumValue: CGFloat = 0.1

    let count = timestamps.count
    guard count > 0 else { return [] }

    let first = timestamps.first!
    let last = timestamps.last!
    let interaval = last.timeIntervalSince(first)
    let chunkSize = barsPerColumn * numberOfColumns
    let chunkedInterval = interaval / TimeInterval(chunkSize)
    let timeChunks = (1 ... chunkSize).map { i in
      first.addingTimeInterval(chunkedInterval * Double(i))
    }

    let filteredRecords = records.filter { record in
      record.graphScore(include: include) >= 0
    }

    var lastTimeChunk = first
    return timeChunks.map { timeChunk in
      let filteredRecords = filteredRecords.filter { record in
        record.timestamp > lastTimeChunk && record.timestamp <= timeChunk
      }
      lastTimeChunk = timeChunk

      let count = filteredRecords.count
      guard count > 0 else { return 0 }

      let sum = filteredRecords.reduce(CGFloat(0.0)) { sum, record in
        sum + CGFloat(record.graphScore(include: include))
      }
      var average = sum / CGFloat(count)

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
      HStack {
        Rectangle().foregroundColor(.clear).frame(width: verticalAxisWidth, height: horizontalAxisHeight)
        horizontalAxis
      }
      HStack {
        verticalAxis
        chart
      }
      .layoutPriority(1)
    }
    .padding(5)
    .overlay(controls, alignment: .bottomTrailing)
    .gesture(magnificationGesture)
    .simultaneousGesture(dragGesture)
  }

  private var magnificationGesture: _EndedGesture<_ChangedGesture<MagnificationGesture>> {
    MagnificationGesture()
      .onChanged { scale in
        guard let newScale = calcNew(scale: scale) else { return }
        graphScale = newScale
        timestamps = calcTimestamps()
      }
      .onEnded { _ in lastGraphScale = graphScale }
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
    AxisLabels(.vertical, data: Array(timestamps.dropFirst().enumerated()), id: \.element) { i, date in
      Text(date.string(for: isDifferentDate(for: i) ? firstPart(of: dateFormat) : lastPart(of: dateFormat)))
        .font(Font.system(size: 8))
        .foregroundColor(isDifferentDate(for: i) ? .primary : .secondary)
        .align(.trailing)
        .frame(width: verticalAxisWidth, height: verticalAxisHeight)
    }
    .frame(width: verticalAxisWidth)
  }

  private func calcTimestamps() -> [Date] {
    guard recordCount > 0 else { return [Date(), Date()] }

    var firstScaledDate: Date
    var scaledInterval: Double

    let minuteInterval: Double = 60
    let factor = Double(numberOfColumns - 1)

    let expansion: Double
    if recordInterval > factor * minuteInterval {
      expansion = floor(recordInterval / factor)
    } else if recordInterval > 1 * minuteInterval {
      expansion = 1
    } else {
      expansion = 24 * 5 * minuteInterval
    }

    let firstDate = firstRecord!.timestamp
    let expandedFirstDate = firstDate.addingTimeInterval(-expansion)
    let lastDate = lastRecord!.timestamp
    let expandedLastDate = lastDate.addingTimeInterval(1)
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

  private func isDifferentDate(for index: Int) -> Bool {
    guard index > 0 else { return true }
    guard index < timestamps.count - 2 else { return true }
    return timestamps[index].string(for: dateFormatDifference) != timestamps[index + 1].string(for: dateFormatDifference)
  }

  private func firstPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).dropLast().joined(separator: " "))
  }

  private func lastPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).last!)
  }

  private func calcNew(scale: CGFloat) -> CGFloat? {
    let calculatedScale = lastGraphScale * scale
    let scaledInterval = recordInterval / Double(calculatedScale)
    let scaledMinutes = scaledInterval / 60
    let scaledHours = scaledMinutes / 60
    let scaledDays = scaledHours / 24

    var roundingFactorInMinutes: Double
    if scaledDays > 96 {
      roundingFactorInMinutes = 6 * 24 * 60
    } else if scaledDays > 24 {
      roundingFactorInMinutes = 1 * 24 * 60
    } else if scaledDays > 12 {
      roundingFactorInMinutes = 0.5 * 24 * 60
    } else if scaledHours > 6 {
      roundingFactorInMinutes = 6 * 60
    } else if scaledHours > Double(numberOfColumns) * 5 / 60 {
      roundingFactorInMinutes = 2 * 60
    } else {
      roundingFactorInMinutes = Double(numberOfColumns) * 5 * 60
    }

    let numberOfMinutesToShow = floor(scaledMinutes / roundingFactorInMinutes) * roundingFactorInMinutes
    let scaleAdjustmentFactor = numberOfMinutesToShow / scaledMinutes

    let newScale = calculatedScale / CGFloat(scaleAdjustmentFactor)
    let adjustedScaledInterval = recordInterval / Double(newScale)
    let adjustedScaledHours = adjustedScaledInterval / 60 / 60

    guard adjustedScaledHours > 0 else { return nil }

    return newScale
  }

  private func calcNew(offset: CGFloat) -> CGFloat? {
    guard graphHeight > 0 else { return nil }

    let firstTimestamp = timestamps.first!
    let lastTimestamp = timestamps.last!
    let interval = lastTimestamp.timeIntervalSince(firstTimestamp)
    let intervalSegment = interval / Double(numberOfColumns * barsPerColumn)

    let adjustment = offset / graphHeight
    let intervalOffset = Int(interval * Double(adjustment) / intervalSegment) * Int(intervalSegment)

    let newGraphOffset = lastGraphOffset - CGFloat(intervalOffset)

    return newGraphOffset
  }

  private func graphSetting(reset: Bool = false, height: CGFloat? = nil) {
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
