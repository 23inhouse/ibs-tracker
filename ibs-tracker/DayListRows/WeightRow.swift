//
//  WeightRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI

struct WeightRowView: View {
  let record: WeightRecord

  init(for record: WeightRecord) {
    self.record = record
  }

  var body: some View {
    DayRowView(type: .weight, color: .secondary, tags: record.tags) {
      TimestampView(record: record as! IBSRecord)
      if let weight = record.weight {
        Text(String(format: "%gkg", weight))
          .font(.body)
          .foregroundColor(.blue)
          .frame(minHeight: 25, alignment: .leading)
      }
    }
  }
}

struct WeightRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      WeightRowView(for: IBSRecord(weight: 57.8, timestamp: Date(), tags: []))
      WeightRowView(for: IBSRecord(weight: 72.0, timestamp: Date(), tags: []))
    }
  }
}
