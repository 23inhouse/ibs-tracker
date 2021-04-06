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

  var foodColor: Color {
    ColorCodedContent.foodColor(for: record as! IBSRecord)
  }

  var body: some View {
    LazyNavigationLink(destination: FoodFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: foodColor, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        if let risk = record.risk {
          PropertyView(
            text: record.riskText(),
            scale: risk.rawValue,
            color: ColorCodedContent.scaleColor(for: record.risk)
          )
        }
        if let size = record.size {
          PropertyView(
            text: record.sizeText(),
            scale: size.rawValue,
            color: ColorCodedContent.foodSizeColor(for: record.size)
          )
        }
        Text(record.text ?? "No meal name recorded")
          .font(.callout)
          .foregroundColor(.secondary)
      }
    }
  }
}

struct FoodRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      FoodRowView(for: IBSRecord(food: "Dinner w/ alot of extra stuff and extra info to display!", timestamp: Date(), tags: ["Pasta"], risk: .extreme, size: .normal))
      FoodRowView(for: IBSRecord(food: "Dinner w/ not much stuff", timestamp: Date(), tags: ["Pasta"], risk: .mild, size: nil))
    }
  }
}
