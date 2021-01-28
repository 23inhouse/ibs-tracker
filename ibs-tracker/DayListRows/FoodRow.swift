//
//  FoodRowView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct FoodRowView: View {
  let record: FoodRecord

  init(for record: FoodRecord) {
    self.record = record
  }

  var body: some View {
    DayRowView(type: .food, color: .secondary, tags: record.tags) {
      TimestampView(record: record as! JSONIBSRecord)
      Text(record.text ?? "No meal name recorded")
        .font(.callout)
        .lineLimit(2)
        .foregroundColor(.secondary)
        .frame(minHeight: 25, alignment: .leading)
    }
  }
}

struct FoodRowView_Previews: PreviewProvider {
  static var previews: some View {
    FoodRowView(for: JSONIBSRecord(food: "Dinner w/ alot of extra stuff and extra info to display!", timestamp: Date(), tags: ["Pasta"], risk: 0, size: 0))
  }
}
