//
//  TimestampView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct TimestampView: View {
  var record: IBSRecord

  var body: some View {
    Text(record.timestamp.string(for: "h:mm a"))
      .font(.callout)
      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
      .frame(alignment: .leading)
  }
}

struct TimestampView_Previews: PreviewProvider {
  static var previews: some View {
    TimestampView(
      record: IBSRecord(timestamp: Date(), tags: ["Pasta"], headache: .moderate, bodyache: .severe)
    )
  }
}
