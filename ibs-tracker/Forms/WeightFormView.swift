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

  private var suggestedTags: [String] {
    return
      appState.tags(for: .weight).filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          availableTag.contains(viewModel.newTag.lowercased())
    }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  private var weights: [Decimal] = {
    Array(stride(from: Decimal(10), to: Decimal(444), by: 0.1))
  }()

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) {
      Section {
        Picker("Weight", selection: $weight) {
          ForEach(weights, id: \.self) { weight in
            Text("\(String(describing: weight))")
              .tag(weight)
          }
        }
        .pickerStyle(InlinePickerStyle())
        .onAppear {
          guard !editMode else { return }
          weight = appState.lastWeight
        }
      }

      SaveButtonSection(name: "Weight", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)

      Section {
        List { EditableTagList(tags: $viewModel.tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $viewModel.newTag, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag) }
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
