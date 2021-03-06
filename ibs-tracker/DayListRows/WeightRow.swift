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
    LazyNavigationLink(destination: WeightFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: .secondary, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        if record.weight != nil {
          Text(record.weightDescription())
            .font(.body)
            .foregroundColor(.secondary)
            .frame(minHeight: 25, alignment: .leading)
        }
      }
    }
  }
}

struct WeightRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      WeightRowView(for: IBSRecord(timestamp: Date(), weight: 57.8, tags: []))
      WeightRowView(for: IBSRecord(timestamp: Date(), weight: 72.0, tags: []))
    }
  }
}
