//
//  MoodFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

struct MoodFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var stress: Scales = .none
  @State private var feel: MoodType = .none

  @State private var showAllTags: Bool = false

  let tagAutoScrollLimit = 3

  init(for moodRecord: MoodRecord? = nil) {
    guard let record = moodRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._stress = State(initialValue: record.stress ?? .none)
    self._feel = State(initialValue: record.feel ?? .none)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, feel: feel, stress: stress)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .mood)
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
        ScaleSlider($feel, "Mood", descriptions: MoodType.descriptions)
        ScaleSlider($stress, "Stress", descriptions: Scales.stressDescriptions)
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: suggestedTags, scroller: scroller)

      if stress != .none || feel != .none {
        SaveButtonSection(name: "Mood", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
    }
  }
}

struct MoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    MoodFormView()
      .environmentObject(IBSData())
  }
}