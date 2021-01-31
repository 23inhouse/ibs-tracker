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

  var moodColor: Color {
    ColorCodedContent.moodColor(for: record.feel)
  }

  var stressColor: Color {
    ColorCodedContent.scaleColor(for: record.stress)
  }

  var body: some View {
    DayRowView(
      type: .mood,
      color: ColorCodedContent.worstColor(moodColor, stressColor),
      tags: record.tags
    ) {
      HStack(alignment: .top, spacing: 0) {
        TimestampView(record: record as! JSONIBSRecord)
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          if let feel = record.feel {
            PropertyView(
              text: record.feelText(),
              scale: feel,
              color: moodColor
            )
          }
          if let stress = record.stress {
            PropertyView(
              text: record.stressText(),
              scale: stress,
              color: stressColor
            )
          }
        }
      }
    }
  }
}

struct MoodRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      MoodRowView(for: JSONIBSRecord(date: Date(), tags: [""], feel: 0, stress: 0))
      MoodRowView(for: JSONIBSRecord(date: Date(), tags: [""], feel: 1, stress: 1))
      MoodRowView(for: JSONIBSRecord(date: Date(), tags: [""], feel: 2, stress: 2))
      MoodRowView(for: JSONIBSRecord(date: Date(), tags: [""], feel: 3, stress: 3))
      MoodRowView(for: JSONIBSRecord(date: Date(), tags: [""], feel: 4, stress: 4))
    }
  }
}
