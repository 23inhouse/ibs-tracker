//
//  SuggestedTagList.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct SuggestedTagList: View {
  @Binding var suggestedTags: [String]
  @Binding var tags: [String]
  @Binding var newTag: String
  @Binding var showAllTags: Bool

  var body: some View {
    ForEach(suggestedTags, id: \.self) { value in
      Button(value) {
        tags.append(value)
        newTag = ""
        showAllTags = false
      }
    }
  }
}

struct SuggestedTagList_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SuggestedTagList(suggestedTags: Binding.constant(["suggested 1", "suggested 2"]), tags: Binding.constant(["tag 1", "tag 2"]), newTag: Binding.constant("suggest"), showAllTags: Binding.constant(false))
        .environmentObject(IBSData())
    }
  }
}
