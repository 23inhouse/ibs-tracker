//
//  TagTextFieldSection.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 10/3/21.
//

import SwiftUI

struct TagTextFieldSection: View {
  @ObservedObject private var viewModel: FormViewModel
  @Binding private var showAllTags: Bool

  private var suggestedTags: [String]
  private var scroller: ScrollViewProxy

  init(_ viewModel: FormViewModel, showAllTags: Binding<Bool>, suggestedTags: [String], scroller: ScrollViewProxy) {
    self._showAllTags = showAllTags
    self.suggestedTags = suggestedTags
    self.viewModel = viewModel
    self.scroller = scroller
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  var body: some View {
    Section {
      List { EditableTagList(tags: $viewModel.tags) }
      HStack {
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $viewModel.newTag, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
          .onTapGesture { viewModel.scrollToTags(scroller: scroller) }
          .onChange(of: viewModel.newTag) { _ in
            showAllTags = false
            viewModel.scrollToTags(scroller: scroller)
          }
        TagToggle(showAllTags: $showAllTags)
      }
      List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag, showAllTags: $showAllTags) }
    }
    .id(ScrollViewProxy.tagAnchor())
  }
}

struct TagTextField_Previews: PreviewProvider {
  static var previews: some View {
    ScrollViewReader { scroller in
      Form {
        TagTextFieldSection(FormViewModel(), showAllTags: Binding.constant(false), suggestedTags: [], scroller: scroller)
        TagTextFieldSection(FormViewModel(), showAllTags: Binding.constant(true), suggestedTags: ["Tag 1", "Tag 2"], scroller: scroller)
      }
    }
  }
}
