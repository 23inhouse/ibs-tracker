//
//  ChartView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/3/21.
//

import Charts
import Shapes
import SwiftUI

struct ChartView: View {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject private var appState: IBSData

  @State private var include: [ItemType] = [.gut, .bm, .ache, .mood, .skin]
  @State var graphScale: CGFloat = 1
  @State var lastGraphScale: CGFloat = 1
  @State var graphOffset: CGFloat = 0
  @State var lastGraphOffset: CGFloat = 0
  @State var graphWidth: CGFloat = 0

  private let options: [ItemType] = [.gut, .bm, .ache, .mood, .skin]
  private let strokeStyle = StrokeStyle(lineWidth: 1.0, lineJoin: .round)

  private let numberOfColumns = 24
  private let horizontalAxisHeight: CGFloat = 20
  private let horizontalAxisWidth: CGFloat = 5
  private let verticalAxisHeight: CGFloat = 100
  private let verticalAxisWidth: CGFloat = 5

  private let barsPerColumn = 4

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  private var coloredColumnChartStyle: ColoredColumnChartStyle<Capsule> {
    ColoredColumnChartStyle(column: Capsule(), spacing: 1, colors: ColorCodedContent.rankedColors.reversed())
  }

  private var recordCount: Int {
    appState.records.count
  }

  private var firstRecord: IBSRecord? {
    appState.records.first
  }

  private var lastRecord: IBSRecord? {
    appState.records.last
  }

  private var recordInterval: TimeInterval {
    let firstDate = firstRecord!.timestamp.date()
    let lastDate = lastRecord!.timestamp.nearest(1, .day).date()
    return lastDate.timeIntervalSince(firstDate)
  }

  private var numberOfDaysRecorded: Int {
    guard recordCount > 0 else { return 0 }
    let firstDate = firstRecord!.timestamp.date()
    let lastDate = lastRecord!.timestamp.nearest(1, .day).date()
    let interaval = lastDate.timeIntervalSince(firstDate)
    return Int(interaval / 60 / 60 / 24)
  }

  private var timestamps: [Date] {
    guard recordCount > 0 else { return [Date().date()] }
    guard recordCount > 1 else { return [firstRecord!.timestamp.date()] }

    let firstDate = firstRecord!.timestamp.date()
    let offsetDate = firstDate.addingTimeInterval(recordInterval / 2)

    let scaledInterval = recordInterval / Double(graphScale)
    let scaledOffsetDate = offsetDate.addingTimeInterval(TimeInterval(graphOffset))

    let firstScaledDate = scaledOffsetDate.addingTimeInterval(-(scaledInterval / 2))

    let chunkedInterval = scaledInterval / TimeInterval(numberOfColumns)
    return (0 ... numberOfColumns).map { i in
      firstScaledDate.addingTimeInterval(chunkedInterval * Double(i))
    }
  }

  private var records: [IBSRecord] {
    guard timestamps.count > 1 else { return [appState.records.first!] }

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

    let first = timestamps.first! //.date()
    let last = timestamps.last! //.nearest(1, .day).date()
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
    guard count > 0 else { return "MMM dd" }

    let first = timestamps.first!.date()
    let last = timestamps.last!.nearest(1, .day).date()
    let interaval = Int(last.timeIntervalSince(first))

    let numberOfColumnsInSeconds = numberOfColumns * 24 * 60 * 60
    return interaval > numberOfColumnsInSeconds ? "MMM dd" : "MMM dd\nHH:mm"
  }

  private var dateFormatDifference: String {
    let count = timestamps.count
    guard count > 0 else { return "MMM" }

    let first = timestamps.first!.date()
    let last = timestamps.last!.nearest(1, .day).date()
    let interaval = Int(last.timeIntervalSince(first))

    let numberOfColumnsInSeconds = numberOfColumns * 24 * 60 * 60
    return interaval > numberOfColumnsInSeconds ? "MMM" : "dd"
  }

  var body: some View {
    HStack {
      VStack {
        verticalAxis
        Rectangle().foregroundColor(.clear).frame(width: verticalAxisWidth, height: horizontalAxisHeight)
      }
      VStack {
        chart
        horizontalAxis
      }
      .layoutPriority(1)
    }
    .padding(5)
    .overlay(controls, alignment: .topTrailing)
    .gesture(magnificationGesture)
    .simultaneousGesture(dragGesture)
  }

  private var magnificationGesture: _EndedGesture<_ChangedGesture<MagnificationGesture>> {
    MagnificationGesture()
      .onChanged { scale in
        guard recordCount > 1 else { return }

        let calculatedScale = lastGraphScale * scale
//        print("scale = [\(scale)]")
//        print("graphScale = [\(graphScale)] calculatedScale [\(calculatedScale)]")

        guard calculatedScale > 1 else {
          graphScale = 1
          graphOffset = 0
          return
        }

        let scaledInterval = recordInterval / Double(calculatedScale)
        let scaledDays = scaledInterval / 60 / 60 / 24
        let roundingFactorInDays: Double = scaledDays > 24 ? 6 : 1

        let numberOfDaysToShow = round(scaledDays / roundingFactorInDays) * roundingFactorInDays
        let scaleAdjustmentFactor = numberOfDaysToShow / scaledDays

        let newScale = calculatedScale / CGFloat(scaleAdjustmentFactor)
        if scale > 1 && newScale < graphScale { return }
        if scale < 1 && newScale > graphScale { return }

//        print("scaledDays = \(scaledDays)")
//        print("numberOfDaysToShow = \(numberOfDaysToShow)")
//        print("scaleAdjustmentFactor = \(scaleAdjustmentFactor)")
        let adjustedScaledInterval = recordInterval / Double(newScale)
        let adjustedScaledDays = adjustedScaledInterval / 60 / 60 / 24
//        print("adjustedScaledDays = \(adjustedScaledDays)")
//        print("calculatedScale [\(calculatedScale)] > newScale [\(newScale)]")

        guard adjustedScaledDays > 0 else { return }
        graphScale = newScale
//        print("timestamps days = \((recordInterval / Double(graphScale)) / 60 / 60 / 24)")
//        print("graphScale = [\(graphScale)]")
      }
      .onEnded { _ in lastGraphScale = graphScale }
  }

  private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
    DragGesture()
      .onChanged { gesture in
        guard graphScale > 1 else { return }

        let offset = gesture.translation.x - 1

        let firstTimestamp = timestamps.first!
        let lastTimestamp = timestamps.last!
        let interval = lastTimestamp.timeIntervalSince(firstTimestamp)
        let intervalSegment = interval / Double(numberOfColumns * barsPerColumn)
//        print("daysOnGraph = \(interval / 60 / 60 / 24)")
//        print("daysPerSegment = \(intervalSegment / 60 / 60 / 24)")

        let adjustment = offset / graphWidth
        let intervalOffset = Int(interval * Double(adjustment) / intervalSegment) * Int(intervalSegment)

        graphOffset = lastGraphOffset - CGFloat(intervalOffset)
      }
      .onEnded { _ in lastGraphOffset = graphOffset }
  }

  private var controls: some View {
    HStack {
      ForEach(options, id: \.self) { itemType in
        TypeShape(type: itemType)
          .stroke(style: strokeStyle)
          .foregroundColor(include.contains(itemType) ? .primary : .secondary)
          .frame(25)
          .backgroundColor(backgroundColor)
          .padding(.vertical, 5)
          .padding(.horizontal, 2)
          .onTapGesture {
            include.toggle(on: !include.contains(itemType), element: itemType)
          }
      }
    }
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.secondary, lineWidth: 0.5)
        .backgroundColor(backgroundColor)
        .cornerRadius(20)
    )
    .padding(10)
  }

  private var chart: some View {
    GeometryReader { geo in
      Chart(data: data)
        .chartStyle(coloredColumnChartStyle)
        .padding(0.5)
        .background(chartGrid)
        .onAppear { graphWidth = geo.width }
    }
  }

  private var chartGrid: some View {
    GridPattern(horizontalLines: Scales.validCases.count + 1, verticalLines: timestamps.count)
      .inset(by: 0)
      .stroke(Color.secondary.opacity(0.5), style: .init(lineWidth: 1, lineCap: .round))
  }

  private var horizontalAxis: some View {
    AxisLabels(.horizontal, data: Array(timestamps.dropLast().enumerated()), id: \.element) { i, date in
      Text(date.string(for: dateFormat))
        .fontWeight(i == 0 || timestamps[i-1].string(for: dateFormatDifference) != date.string(for: dateFormatDifference) ? .bold : .regular)
        .font(Font.system(size: 7))
        .foregroundColor(.secondary)
        .align(.trailing)
        .rotate(Angle(degrees: -90))
        .fixedSize()
        .frame(width: horizontalAxisWidth, height: horizontalAxisHeight)
    }
    .frame(height: horizontalAxisHeight)
    .padding(.horizontal, 1)
  }

  private var verticalAxis: some View {
    AxisLabels(.vertical, data: Scales.validCases.reversed(), id: \.self) { scale in
      Text(scale.label())
        .fontWeight(.bold)
        .font(Font.system(size: 8))
        .foregroundColor(ColorCodedContent.scaleColor(for: scale))
        .rotate(Angle(degrees: -90))
        .fixedSize()
        .frame(width: verticalAxisWidth, height: verticalAxisHeight)
    }
    .frame(width: verticalAxisWidth)
  }
}

struct ChartView_Previews: PreviewProvider {
  static var previews: some View {
    ChartView()
      .environmentObject(IBSData())
  }
}
