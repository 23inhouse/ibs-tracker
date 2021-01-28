//
//  BowelMovementRowView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct BowelMovementRowView: View {
  let record: BMRecord

  init(for record: BMRecord) {
    self.record = record
  }

  var body: some View {
    DayRowView(type: .bm, color: .primary, bristolType: record.bristolType, tags: record.tags) {
      TimestampView(record: record as! JSONIBSRecord)
      Text(record.bristolDescription())
        .font(.callout)
        .foregroundColor(.secondary)
        .frame(height: 25, alignment: .leading)
        .lineLimit(1)
    }
  }
}

struct BowelMovementRowView_Previews: PreviewProvider {
  static var previews: some View {
    BowelMovementRowView(for: JSONIBSRecord(bristolScale: 4, date: Date(), tags: ["Almost sausage"]))
  }
}
