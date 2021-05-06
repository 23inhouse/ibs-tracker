//
//  SummaryRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/4/21.
//

import SwiftUI

struct SummaryRowView: View {
  let records: [IBSRecord]
  let filters: [ItemType]

  init(_ dayRecord: DayRecord, filters: [ItemType] = []) {
    self.records = dayRecord.records.reversed()
    self.filters = filters.isNotEmpty ? filters : IBSRecord.summaryTypes
  }

  private let groups: [ItemType: [ItemType]] = [
    .food: [.food],
    .medication: [.medication],
    .gut: [.skin, .gut, .ache, .mood],
    .bm: [.bm],
  ]

  private let rowHeight: CGFloat = 16
  private let rowPadding: CGFloat = UIScreen.mainWidth / 31
  private let dotRadius: CGFloat = 4
  private let strokeStyle = StrokeStyle(lineWidth: 0.65, lineJoin: .round)

  private let hourInSeconds: Double = 60 * 60

  private var keys: [ItemType] {
    filtered(keys: [.food, .medication, .gut, .bm])
  }

  private var date: Date {
    guard let firstRecord = records.first else { return IBSData.timeShiftedDate().date() }
    return IBSData.timeShiftedDate(for: firstRecord.timestamp).date()
  }

  private var data: [ItemType: [IBSRecord]] {
    Dictionary(grouping: records.filter(\.isSummary)) { record in
      if record.type == .food && record.medicinal == true {
        return .medication
      }
      return record.type
    }
  }

  private var dayStartTime: Date {
    let startHour = TimeInterval(IBSData.numberOfHoursInMorningIncludedInPreviousDay) * hourInSeconds
    return date.addingTimeInterval(startHour)
  }

  private var count: Int {
    keys.compactMap { $0 }.count
  }

  private var summaryHeight: CGFloat {
    CGFloat(count) * rowHeight
  }

  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 0) {
        keyShapes
        Color.clear
          .frame(width: rowHeight + 5)
      }
      VStack(spacing: 5) {
        summary
          .frame(height: summaryHeight)
        TimelineView()
          .padding(.horizontal, -rowPadding)
      }
      Spacer()
        .frame(width: 5)
    }
    .padding(.horizontal, 5)
    .padding(.vertical, 10)
  }

  var keyShapes: some View {
    ForEach(keys, id: \.self) { key in
      TypeShape(type: key)
        .stroke(style: strokeStyle)
        .foregroundColor(.secondary)
        .frame(width: rowHeight - 3, height: rowHeight - 3)
        .frame(width: rowHeight, height: rowHeight)
    }
  }

  var summary: some View {
    GeometryReader { geomentry in
      ForEach(keys, id: \.self) { key in
        let records = flatRecords(key: key)

        ForEach(records, id: \.self) { record in
          dot(for: record, on: rowIndex(of: key), in: geomentry)
          if key == .food && record.mealStart == true && record.mealEnd == true {
            let endRecord = endingAt(record)
            dot(for: endRecord, on: rowIndex(of: key), in: geomentry)
            meal(for: [record, endRecord], on: rowIndex(of: key), in: geomentry)
          }
        }
        if key == .food {
          meal(for: records, on: rowIndex(of: key), in: geomentry)
        }
      }
    }
  }

  private func endingAt(_ record: IBSRecord) -> IBSRecord {
    var endRecord = record
    let durationInSeconds = record.durationInMinutes * 60
    endRecord.timestamp = record.timestamp.addingTimeInterval(durationInSeconds)
    return endRecord
  }

  private func filtered(keys: [ItemType]) -> [ItemType] {
    keys.filter { Set(groups[$0] ?? []).intersection(Set(filters)).count > 0 }
  }

  private func flatRecords(key: ItemType) -> [IBSRecord] {
    (groups[key] ?? []).map({ itemType in data[itemType] ?? [] }).flatMap { $0 }
  }

  private func rowIndex(of key: ItemType) -> Int {
    keys.firstIndex(of: key) ?? -1
  }

  private func dot(for record: IBSRecord, on row: Int, in geometry: GeometryProxy) -> some View {
    let time = record.timestamp
    let xOffset = CGFloat(percentage(of: time)) * width(in: geometry)
    let yOffset = offset(for: row)

    return Circle()
      .fill(ColorCodedContent.color(for: record))
      .frame(width: dotRadius * 2, height: dotRadius * 2)
      .offset(x: -dotRadius, y: -dotRadius)
      .offset(xOffset, yOffset)
  }

  private func percentage(of time: Date) -> Double {
    let totalHoursInSeconds = Double(TimelineView.timestamps.count + 1) * hourInSeconds
    return time.timeIntervalSince(dayStartTime) / totalHoursInSeconds
  }

  private func width(in geometry: GeometryProxy) -> CGFloat {
    return geometry.width + (rowPadding * 2) + dotRadius
  }

  private func offset(for row: Int) -> CGFloat {
    CGFloat(row) * rowHeight + rowHeight / 2
  }

  private func meal(for records: [IBSRecord], on row: Int, in geometry: GeometryProxy) -> some View {
    let meals = Dictionary(grouping: records, by: \.mealType)
    return ForEach(Array(meals.keys), id: \.self) { key in
      lines(for: meals[key]!, on: row, in: geometry)
    }
  }

  private func lines(for records: [IBSRecord], on row: Int, in geometry: GeometryProxy) -> some View {
    let pairs: [(IBSRecord, IBSRecord)]
    if records.count == 1 {
      pairs = Array(zip(records, records))
    } else {
      pairs = Array(zip(records.dropLast(), records.dropFirst()))
    }

    let minDuration: Double = 15 * 60
    return ForEach(pairs, id: \.0) { (first, last) in
      if last.timestamp.timeIntervalSince(first.timestamp) > minDuration {
        line(from: first, to: last, on: row, in: geometry)
      }
    }
  }

  private func line(from firstRecord: IBSRecord, to lastRecord: IBSRecord, on row: Int, in geometry: GeometryProxy) -> some View {
    let height = dotRadius

    let dayStartTime = date.addingTimeInterval(TimeInterval(IBSData.numberOfHoursInMorningIncludedInPreviousDay * 60 * 60))

    let firstTime = firstRecord.timestamp.timeIntervalSince(dayStartTime)
    let lastTime = lastRecord.timestamp.timeIntervalSince(dayStartTime)

    let firstColor = ColorCodedContent.color(for: firstRecord)
    let lastColor = ColorCodedContent.color(for: lastRecord)

    let dayInHours = 24 * CGFloat(hourInSeconds)
    let xOffset1 = CGFloat(firstTime) / dayInHours * (geometry.width - 1)
    let xOffset2 = CGFloat(lastTime) / dayInHours * (geometry.width - 1)
    let width = xOffset2 - xOffset1

    let yOffset = offset(for: row)

    let gradient = Gradient(colors: [firstColor, lastColor])
    let fill = LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
    return Rectangle()
      .fill(fill)
      .frame(width: width, height: height * 2)
      .offset(x: 0, y: -height)
      .offset(xOffset1, yOffset)
  }
}

struct SummaryRowView_Previews: PreviewProvider {
  static func time(at hour: Double) -> Date {
    Date().date().addingTimeInterval(hour * 60 * 60)
  }

  static let normalDay = [
    IBSRecord(timestamp: time(at: 9), food: "coffee", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 10), food: "porridge", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 13.5), food: "lunch", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 18.5), food: "dinner", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 19), food: "dinner", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 20), food: "dinner", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 8.5), bristolScale: .b4, tags: []),
  ]
  static let everyType = [
    IBSRecord(timestamp: time(at: 9), note: "note"),
    IBSRecord(timestamp: time(at: 8), food: "coffee", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
    IBSRecord(timestamp: time(at: 14), food: "medical milk", tags: [], risk: nil, size: nil, speed: nil, medicinal: true),
    IBSRecord(timestamp: time(at: 11), bristolScale: .b4, tags: []),
    IBSRecord(timestamp: time(at: 16), bloating: .mild, pain: Scales.none),
    IBSRecord(timestamp: time(at: 17), feel: .bad, stress: .mild),
    IBSRecord(timestamp: time(at: 18), headache: .severe, bodyache: .mild),
    IBSRecord(timestamp: time(at: 19), condition: .extreme, text: "ulcer"),
    IBSRecord(timestamp: time(at: 7), medication: "goodgut", type: [.prokinetic]),
    IBSRecord(timestamp: time(at: 7), weight: 60),
  ]
  static let fullDay = Array((1 ..< 24)).flatMap { hour -> [IBSRecord] in
    let hour = Double(hour + 4)
    return [
      IBSRecord(timestamp: time(at: hour), food: "coffee", tags: [], risk: nil, size: nil, speed: nil, medicinal: false),
      IBSRecord(timestamp: time(at: hour), bristolScale: .b4, tags: []),
    ]
  }
  static var previews: some View {
    List {
      SummaryRowView(DayRecord(date: time(at: 0), records: normalDay.sorted(by: { $0.timestamp > $1.timestamp })))
        .listRowInsets(EdgeInsets())
      SummaryRowView(DayRecord(date: time(at: 0), records: everyType.sorted(by: { $0.timestamp > $1.timestamp })))
        .listRowInsets(EdgeInsets())
      SummaryRowView(DayRecord(date: time(at: 0), records: fullDay.sorted(by: { $0.timestamp > $1.timestamp })))
        .listRowInsets(EdgeInsets())
    }
  }
}

struct TimelineView: View {
  static var timestamps: [Date] {
    (0 ... 24).map { hour in
      let hour = Double(IBSData.numberOfHoursInMorningIncludedInPreviousDay + (hour))
      return Date().date().addingTimeInterval(hour * 60 * 60)
    }
  }

  static private var evenTimestamps: [Date] {
    timestamps.enumerated().compactMap { (i, record) in i % 2 == 0 ? record : nil }
  }

  private let rowPadding: CGFloat = UIScreen.mainWidth / 31

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top, spacing: 0) {
        ForEach(Array(TimelineView.timestamps.enumerated()), id: \.element) { i, date in
          Color.secondary
            .frame(width: 1, height: i % 2 == 0 ? 5 : 2.5)
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.horizontal, rowPadding / 2.23)
      HStack(spacing: 0) {
        ForEach(Array(TimelineView.evenTimestamps.enumerated()), id: \.element) { i, date in
          time(for: date, index: i)
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.horizontal, -2)
    }
  }

  private func time(for date: Date, index: Int) -> some View {
    let demarkation: Bool = (index - 1) % 2 == 0
    let hour = date.string(for: "h").lowercased()
    let ampm = date.string(for: demarkation ? "a" : "").lowercased()
    let fontSize: CGFloat = 8
    let fontSizeLarge = fontSize + 1
    let fontSizeSmaller = fontSize - 2

    return HStack(alignment: .top, spacing: 0) {
      Group {
        Text(hour)
          .font(Font.system(size: demarkation ?  fontSizeLarge : fontSize))
          .fontWeight(demarkation ? .heavy : .light)
          .align(.trailing)
        if ampm.isNotEmpty {
          Text(ampm)
            .font(Font.system(size: fontSizeSmaller))
            .fontWeight(.light)
            .align(.leading)
        }
      }
    }
    .foregroundColor(.secondary)
  }
}
