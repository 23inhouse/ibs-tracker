//
//  SymptomsVerticalAxisView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 29/3/21.
//

import SwiftUI

struct SymptomsVerticalAxisView: View {
  @Binding var timestamps: [Date]

  var verticalAxisWidth: CGFloat
  var numberOfColumns: Int

  private var dateFormat: String {
    let count = timestamps.count
    guard count > 1 else { return "MMM dd" }

    let first = timestamps.first!
    let last = timestamps.last!
    let interaval = last.timeIntervalSince(first)

    let oneDay: Double = 24 * 60 * 60
    let oneDayPerColumn = Double(numberOfColumns - 1) * oneDay
    let daysToSplit = oneDayPerColumn / 2
    return interaval > daysToSplit ? "MMM dd" : "MMM dd\nHH:mm"
  }

  private var dateFormatDifference: String {
    return dateFormat == "MMM dd" ? "MMM" : "dd"
  }

  var body: some View {
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

  private func isDifferentDate(for index: Int) -> Bool {
    guard index > 0 else { return true }
    guard index < timestamps.count - 1 else { return true }
    let prevDate = timestamps[index - 1]
    let nextDate = timestamps[index]
    return prevDate.string(for: dateFormatDifference) != nextDate.string(for: dateFormatDifference)
  }

  private func firstPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).dropLast().joined(separator: " "))
  }

  private func lastPart(of dateFormat: String) -> String {
    return String(describing: dateFormat.split(whereSeparator: \.isWhitespace).last!)
  }
}

struct SymptomsVerticalAxisView_Previews: PreviewProvider {
  static let timestamp = Date().nearest(5, .minute)
  static let timestamps = Binding.constant([timestamp, timestamp, timestamp])
  static var previews: some View {
    SymptomsVerticalAxisView(timestamps: timestamps, verticalAxisWidth: 40, numberOfColumns: 24)
      .environmentObject(IBSData())
  }
}
