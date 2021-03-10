//
//  TagToggle.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

struct TagToggle: View {
  @Binding var showAllTags: Bool

  private var showAllTagsIcon: String {
    showAllTags ? "chevron.up" : "chevron.down"
  }

  var body: some View {
    Image(systemName: showAllTagsIcon)
      .foregroundColor(.secondary)
      .onTapGesture { showAllTags.toggle() }
  }
}

struct TagToggle_Previews: PreviewProvider {
  static var previews: some View {
    List {
      TagToggle(showAllTags: Binding.constant(true))
      TagToggle(showAllTags: Binding.constant(false))
    }
  }
}
