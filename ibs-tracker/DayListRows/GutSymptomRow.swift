//
//  GutSymptomRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct GutSymptomRowView: View {
  let record: GutRecord

  init(for record: GutRecord) {
    self.record = record
  }

  var body: some View {
    DayRowView(
      type: .gut,
      color: ColorCodedContent.scaleColor(for: record.gutScore()),
      tags: record.tags
    ) {
      HStack(alignment: .top, spacing: 0) {
        TimestampView(record: record as! JSONIBSRecord)
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          if let bloating = record.bloating {
            PropertyView(
              text: record.bloatingText(),
              scale: bloating,
              color: ColorCodedContent.scaleColor(for: record.bloating)
            )
          }
          if let pain = record.pain {
            PropertyView(
              text: record.gutPainText(),
              scale: pain,
              color: ColorCodedContent.scaleColor(for: record.pain)
            )
          }
        }
      }
    }
  }
}

struct GutSymptomRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack{
      GutSymptomRowView(for: JSONIBSRecord(date: Date(), tags: ["Gurgling sound"], bloating: 0, pain: 0))
      GutSymptomRowView(for: JSONIBSRecord(date: Date(), tags: ["Gurgling sound"], bloating: 1, pain: 1))
      GutSymptomRowView(for: JSONIBSRecord(date: Date(), tags: ["Gurgling sound"], bloating: 2, pain: 2))
      GutSymptomRowView(for: JSONIBSRecord(date: Date(), tags: ["Gurgling sound"], bloating: 3, pain: 3))
      GutSymptomRowView(for: JSONIBSRecord(date: Date(), tags: ["Gurgling sound"], bloating: 4, pain: 4))
    }
  }
}
