//
//  FormViewModel.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import Foundation

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

  func addNewTag() {
    let cleanedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard cleanedTag.count > 0 else { return }

    tags.append(cleanedTag)
    newTag = ""
  }

  func setCurrentTimestamp() {
    guard timestamp == nil else { return }
    timestamp = Date().nearest(5, .minute)
  }

  func showTagSuggestions(_ isEditing: Bool) {
    isEditingTags = isEditing
  }
}