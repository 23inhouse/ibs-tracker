//
//  EditableTagList.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct EditableTagList: View {
  @Binding var tags: [String]

  private var editableTags: [String] { tags }

  var body: some View {
    ForEach(tags.indices, id: \.self) { i in
      if editableTags.indices.contains(i) {
        HStack {
          TextField("", text: Binding(
            get: { self.tags[i] },
            set: { self.tags[i] = $0 }
          ))

          Button(action: {
            tags.remove(at: i)
          }, label: {
            Image(systemName: "xmark.circle")
          })
        }
      }
    }
  }
}

struct EditableTagList_Previews: PreviewProvider {
  static var previews: some View {
    List {
      EditableTagList(tags: Binding.constant(["tag 1", "tag 2"]))
        .environmentObject(IBSData())
    }
  }
}
