//
//  BMRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct BMRowView: View {
  let record: BMRecord

  init(for record: BMRecord) {
    self.record = record
  }

  private var scale: BristolType {
    record.bristolScale ?? .b3
  }

  private var color: Color {
    ColorCodedContent.bristolColor(for: scale)
  }

  var body: some View {
    LazyNavigationLink(destination: BMFormView(for: record)) {
      DayRowView(record as! IBSRecord, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        HStack {
          Image(systemName: "\(scale.rawValue).circle")
            .resizedToFit()
            .foregroundColor(color)
            .frame(15)
          Text(record.bristolDescription())
            .font(.callout)
            .foregroundColor(.secondary)
            .frame(height: 25, alignment: .leading)
            .lineLimit(1)
        }
      }
    }
  }
}

struct BowelMovementRowView_Previews: PreviewProvider {
  static var previews: some View {
    BMRowView(for: IBSRecord(bristolScale: .b4, timestamp: Date(), tags: ["Almost sausage"]))
  }
}
