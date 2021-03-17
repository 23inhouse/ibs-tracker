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
    LazyNavigationLink(destination: FoodFormView(for: record)) {
      DayRowView(type: .food, color: .secondary, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        Group {
          Text(record.text ?? "No meal name recorded")
            .font(.callout)
            .foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          if let risk = record.risk {
            PropertyView(
              text: record.riskText(),
              scale: risk.rawValue,
              color: ColorCodedContent.scaleColor(for: record.risk),
              direction: .leftToRight
            )
          }
          if let size = record.size {
            PropertyView(
              text: record.sizeText(),
              scale: size.rawValue,
              color: ColorCodedContent.foodColor(for: record.size),
              direction: .leftToRight
            )
          }
        }
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
