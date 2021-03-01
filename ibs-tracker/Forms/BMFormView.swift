//
//  BMFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 28/2/21.
//

import SwiftUI

struct BMFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var bristolScale: BristolType? = nil
  @State private var color: BMColor = .none
  @State private var dryness: Scales = .none
  @State private var evacuation: BMEvacuation = .none
  @State private var pressure: Scales = .none
  @State private var smell: BMSmell = .none
  @State private var wetness: Scales = .none

  @State private var scale: Double = 0

  init(for bmRecord: BMRecord? = nil) {
    guard let record = bmRecord else { return }
    self.editableRecord = bmRecord
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._bristolScale = State(initialValue: record.bristolScale)
    self._color = State(initialValue: record.color ?? .none)
    self._dryness = State(initialValue: record.dryness ?? .none)
    self._evacuation = State(initialValue: record.evacuation ?? .none)
    self._pressure = State(initialValue: record.pressure ?? .none)
    self._smell = State(initialValue: record.smell ?? .none)
    self._wetness = State(initialValue: record.wetness ?? .none)
  }

  private var bristolScaleDescription: String {
    guard let bristolScale = bristolScale else { return "Track you poop" }
    return BristolType.descriptions[bristolScale] ?? ""
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(bristolScale: bristolScale, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, color: color, pressure: pressure, smell: smell, evacuation: evacuation, dryness: dryness, wetness: wetness)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .bm)
      .filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          (
            availableTag.contains(viewModel.newTag.lowercased()) ||
              viewModel.newTag.isEmpty
          )
    }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) {
      Section {
        bristolTypePicker
      }

      Section {
        evacuationPicker
      }

      Section {
        smellPicker
        colorPicker
      }

      Section {
        ScaleSlider($pressure, "Pressure", descriptions: Scales.pressureDescriptions)
        ScaleSlider($wetness, "Wetness", descriptions: Scales.wetnessDescriptions)
        ScaleSlider($dryness, "Dryness", descriptions: Scales.drynessDescriptions)
      }

      Section {
        List { EditableTagList(tags: $viewModel.tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $viewModel.newTag, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag) }
      }

      if bristolScale != nil {
        SaveButtonSection(name: "Bowel Movement", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
    }
  }

  private var bristolTypePicker: some View {
    VStack {
      Text(bristolScaleDescription)
        .foregroundColor(ColorCodedContent.bristolColor(for: bristolScale))
      HStack {
        ForEach(Range(0...7)) { scale in
          let scale = BristolType(rawValue: Int(scale))
          BristolView(scale: scale, frameSize: 29.5, foregroundColor: foregroundColor(for: scale))
            .frame(maxWidth: .infinity)
            .onTapGesture {
              bristolScale = scale
            }
        }
      }
    }
  }

  private var colorPicker: some View {
    Picker("Color", selection: $color) {
      ForEach(BMColor.allCases, id: \.self) { color in
        Text(color.rawValue.capitalized)
          .tag(color)
      }
    }
  }

  private var evacuationPicker: some View {
    VStack {
      Text("\(BMEvacuation.descriptions[evacuation]?.capitalized ?? "") Evacuation")
        .foregroundColor(.secondary)
      Picker("Evacuation", selection: $evacuation) {
        ForEach(BMEvacuation.allCases, id: \.self) { evacuation in
          Text(evacuation.rawValue.capitalized)
            .tag(evacuation)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private var smellPicker: some View {
    Picker("Smell", selection: $smell) {
      ForEach(BMSmell.allCases, id: \.self) { smell in
        Text(BMSmell.descriptions[smell]?.capitalized ?? "")
          .tag(smell)
      }
    }
  }

  private func foregroundColor(for scale: BristolType?) -> Color? {
    scale == bristolScale ? nil : .secondary
  }
}

struct BMFormView_Previews: PreviewProvider {
  static var previews: some View {
    BMFormView()
      .environmentObject(IBSData())
  }
}
