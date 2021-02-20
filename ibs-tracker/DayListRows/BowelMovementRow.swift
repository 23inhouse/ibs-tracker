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
    DayRowView(type: .bm, color: .primary, bristolScale: record.bristolScale, tags: record.tags) {
      TimestampView(record: record as! IBSRecord)
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
    BowelMovementRowView(for: IBSRecord(bristolScale: 4, timestamp: Date(), tags: ["Almost sausage"]))
  }
}
