//
//  TagCloudView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI

struct TagCloudView: View {
  let fonts: [Int:Font] = [
    1: .subheadline,
    2: .subheadline,
    3: .footnote,
    4: .caption,
  ]

  var tags: [String]
  var resize: Bool = false

  var font: Font {
    guard resize else { return .footnote }
    return fonts[tags.count] ?? .caption2
  }

  var unwrappableTags: [String] {
    tags.map { tag in
      String(tag.replacingOccurrences(of: " ", with: "\u{00a0}"))
    }
  }

  var body: some View {
    Text(unwrappableTags.map { $0.firstUppercased }.joined(separator: ", "))
      .align(.trailing)
      .frame(maxWidth: .infinity, alignment: .trailing)
      .font(font)
      .foregroundColor(.blue)
  }
}

struct TagCloudView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      TagCloudView(tags: ["tow words", "apple", "google", "amazon", "Microsoft"])
      TagCloudView(tags: ["full evacuation", "Mr whippy", "Sweet smelling", "Good color", "Best so far", "medium pressure", "high pressure", "Tags need a maximum length"])
      TagCloudView(tags: ["one tag"], resize: true)
      TagCloudView(tags: ["tow words", "apple"], resize: true)
      TagCloudView(tags: ["more words", "apple", "google"], resize: true)
      TagCloudView(tags: ["morer words", "apple", "google", "amazon", "Microsoft"], resize: true)
      TagCloudView(tags: ["morry words", "apple", "google", "amazon", "Microsoft", "Oracle", "Facebook", "full evacuation", "Mr whippy", "Sweet smelling", "Good color", "Best so far", "medium pressure", "high pressure", "Tags need a maximum length"], resize: true)
    }
  }
}
