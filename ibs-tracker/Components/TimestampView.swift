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
    Text("\(record.dateString(for: "h:mm a"))")
      .font(.callout)
      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
      .frame(alignment: .leading)
  }
}

struct TimestampView_Previews: PreviewProvider {
  static var previews: some View {
    TimestampView(
      record: IBSRecord(date: Date(), tags: ["Pasta"], headache: 3, pain: 4)
    )
  }
}
