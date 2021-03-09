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
    NavigationLink(destination: GutFormView(for: record)) {
      DayRowView(
        type: .gut,
        color: ColorCodedContent.scaleColor(for: record.gutScore()),
        tags: record.tags
      ) {
        HStack(alignment: .top, spacing: 0) {
          TimestampView(record: record as! IBSRecord)
          Spacer()
          VStack(alignment: .trailing, spacing: 4) {
            if let bloating = record.bloating {
              PropertyView(
                text: record.bloatingText(),
                scale: bloating.rawValue,
                color: ColorCodedContent.scaleColor(for: record.bloating)
              )
            }
            if let pain = record.pain {
              PropertyView(
                text: record.gutPainText(),
                scale: pain.rawValue,
                color: ColorCodedContent.scaleColor(for: record.pain)
              )
            }
          }
        }
      }
    }
  }
}

struct GutSymptomRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack{
      GutSymptomRowView(for: IBSRecord(timestamp: Date(), tags: ["Gurgling sound"], bloating: .zero, pain: .zero))
      GutSymptomRowView(for: IBSRecord(timestamp: Date(), tags: ["Gurgling sound"], bloating: .mild, pain: .mild))
      GutSymptomRowView(for: IBSRecord(timestamp: Date(), tags: ["Gurgling sound"], bloating: .moderate, pain: .moderate))
      GutSymptomRowView(for: IBSRecord(timestamp: Date(), tags: ["Gurgling sound"], bloating: .severe, pain: .severe))
      GutSymptomRowView(for: IBSRecord(timestamp: Date(), tags: ["Gurgling sound"], bloating: .extreme, pain: .extreme))
    }
  }
}
