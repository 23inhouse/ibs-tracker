//
//  TagToggle.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

struct TagToggle: View {
  @Binding var showAllTags: Bool

  var scroller: ScrollViewProxy? = nil

  private var showAllTagsIcon: String {
    showAllTags ? "chevron.up" : "chevron.down"
  }

  var body: some View {
    Image(systemName: showAllTagsIcon)
      .foregroundColor(.secondary)
      .onTapGesture {
        showAllTags.toggle()

        guard showAllTags && scroller != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          scroller!.scrollTo(id: .info)
          endEditing(true)
        }
      }
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
