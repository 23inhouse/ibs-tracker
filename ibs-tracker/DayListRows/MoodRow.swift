//
//  MoodRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI

struct MoodRowView: View {
  let record: MoodRecord

  init(for record: MoodRecord) {
    self.record = record
  }

  private var moodColor: Color {
    ColorCodedContent.moodColor(for: record.feel)
  }

  private var stressColor: Color {
    ColorCodedContent.scaleColor(for: record.stress)
  }

  private var worstColor: Color {
    ColorCodedContent.worstColor(moodColor, stressColor)
  }

  var body: some View {
    LazyNavigationLink(destination: MoodFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: worstColor, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        if let feel = record.feel {
          PropertyView(
            text: record.feelText(),
            scale: feel.rawValue,
            color: moodColor
          )
        }
        if let stress = record.stress {
          PropertyView(
            text: record.stressText(),
            scale: stress.rawValue,
            color: stressColor
          )
        }
      }
    }
  }
}

struct MoodRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: MoodType.none, stress: .zero))
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: .good, stress: Scales.none))
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: .soso, stress: .mild))
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: .bad, stress: .moderate))
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: .awful, stress: .severe))
      MoodRowView(for: IBSRecord(timestamp: Date(), tags: [""], feel: .extreme, stress: .extreme))
    }
  }
}
