//
//  FormViewModel.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

class FormViewModel: ObservableObject {
  @Published var timestamp: Date?
  @Published var isValidTimestamp: Bool = true
  @Published var tags = [String]()
  @Published var newTag = ""
  @Published var showAlert: Bool = false
  @Published var isEditingTags: Bool = false

  convenience init(timestamp: Date?, tags: [String]) {
    self.init()
    self.timestamp = timestamp
    self.tags = tags
  }

  private let tagAutoScrollLimit = 3

  func addNewTag() {
    let cleanedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard cleanedTag.count > 0 else { return }

    tags.append(cleanedTag)
    newTag = ""
  }

  func initializeTimestamp() {
    guard timestamp == nil else { return }
    timestamp = Date().nearest(5, .minute)
  }

  func scrollTo(_ id: Int, scroller: ScrollViewProxy) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
      guard let self = self else { return }
      guard self.tags.count < self.tagAutoScrollLimit else { return }
      scroller.scrollTo(id, anchor: .top)
    }
  }

  func scrollToTags(scroller: ScrollViewProxy) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
      guard let self = self else { return }
      guard self.tags.count < self.tagAutoScrollLimit else { return }
      scroller.scrollToTags()
    }
  }

  func showTagSuggestions(_ isEditing: Bool) {
    isEditingTags = isEditing
  }
}
