//
//  GutFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

struct GutFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var bloating: Scales = .none
  @State private var pain: Scales = .none

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

  init(for gutRecord: GutRecord? = nil) {
    guard let record = gutRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._bloating = State(initialValue: record.bloating ?? .none)
    self._pain = State(initialValue: record.pain ?? .none)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, bloating: bloating, pain: pain)
  }

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      (bloating != .none || pain != .none)
  }

  var body: some View {
    FormView("Pain / Bloating", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        ScaleSlider($pain, "Pain", descriptions: Scales.gutPainDescriptions)
        ScaleSlider($bloating, "Bloating", descriptions: Scales.bloatingDescriptions)
      }
      .scrollID(.info)

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, onEditingChanged: viewModel.showTagSuggestions, scroller: scroller)

      SaveButtonSection(name: "Gut", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp, scroller: scroller)
    }
    .onAppear {
      calcSuggestedTags()
    }
    .onChange(of: [showAllTags]) { _ in
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.tags, [viewModel.newTag]]) { _ in
      calcSuggestedTags()
    }
  }

  private func calcSuggestedTags() {
    DispatchQueue.main.async {
      suggestedTags = appState.tags(for: .gut)
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
  }
}

struct GutFormView_Previews: PreviewProvider {
  static var previews: some View {
    GutFormView()
      .environmentObject(IBSData())
  }
}
