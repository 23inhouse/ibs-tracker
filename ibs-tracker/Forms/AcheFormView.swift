//
//  AcheFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

struct AcheFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var bodyache: Scales = .none
  @State private var headache: Scales = .none

  @State private var showAllTags: Bool = false

  let tagAutoScrollLimit = 3

  init(for acheRecord: AcheRecord? = nil) {
    guard let record = acheRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._bodyache = State(initialValue: record.bodyache ?? .none)
    self._headache = State(initialValue: record.headache ?? .none)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, headache: headache, bodyache: bodyache)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .ache)
      .sorted()
      .filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          (
            showAllTags ||
            availableTag.contains(viewModel.newTag.lowercased())
        )
    }
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        ScaleSlider($headache, "Headache", descriptions: Scales.headacheDescriptions)
        ScaleSlider($bodyache, "Other body pain", descriptions: Scales.bodyacheDescriptions)
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: suggestedTags, scroller: scroller)

      if bodyache != .none || headache != .none {
        SaveButtonSection(name: "Ache", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
    }
  }
}

struct AcheFormView_Previews: PreviewProvider {
  static var previews: some View {
    AcheFormView()
      .environmentObject(IBSData())
  }
}
