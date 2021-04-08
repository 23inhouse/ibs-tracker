//
//  WeightFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/3/21.
//

import SwiftUI

struct WeightFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var weight: Decimal = 0

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

  init(for weightRecord: WeightRecord? = nil) {
    guard let record = weightRecord else { return }
    self.editableRecord = weightRecord
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._weight = State(initialValue: record.weight ?? 0)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(weight: weight, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags)
  }

  private var savable: Bool {
    viewModel.isValidTimestamp
  }

  var body: some View {
    FormView("Weight", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        WeightPicker(weight: $weight)
          .pickerStyle(InlinePickerStyle())
          .scaleEffect(x: 0.33, y: 1.0, anchor: .center)
          .onAppear {
            guard !editMode else { return }
            weight = appState.lastWeight
          }
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, scroller: scroller)

      SaveButtonSection(name: "Weight", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp)
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
      suggestedTags = appState.tags(for: .weight)
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

struct WeightFormView_Previews: PreviewProvider {
  static var previews: some View {
    WeightFormView()
      .environmentObject(IBSData())
  }
}

struct WeightPicker: View {
  @Binding var weight: Decimal

  private let maxWeight: Decimal = 140.1
  private let minWeight: Decimal = 40

  private var weights: [Decimal] {
    return Array(stride(from: minWeight, to: maxWeight, by: 0.1))
  }

  var body: some View {
    Picker("Weight", selection: $weight) {
      ForEach(weights, id: \.self) { weight in
        Text("\(String(describing: weight)) kg")
          .scaleEffect(x: 3.0, y: 1.0, anchor: .center)
          .tag(weight)
      }
    }
  }
}
