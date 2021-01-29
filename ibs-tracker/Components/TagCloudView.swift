//
//  TagCloudView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI

struct TagCloudView: View {
  let fonts: [Int:Font] = [
    1: .body,
    2: .callout,
    3: .caption
  ]

  var tags: [String]
  var resize: Bool = false

  var font: Font {
    guard resize == true else { return .caption }
    return fonts[tags.count] ?? .caption2
  }

  var body: some View {
    Text(tags.map { $0.firstUppercased }.joined(separator: ", "))
      .font(font)
      .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
  }
}

struct TagCloudView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TagCloudView(tags: ["tow words", "apple", "google", "amazon", "Microsoft", "Oracle", "Facebook", "full evacuation", "Mr whippy", "Sweet smelling", "Good color", "Best so far", "medium pressure", "high pressure", "Tags need a maximum length"])
        .frame(width: 220)
    }
  }
}
