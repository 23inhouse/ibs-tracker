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

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

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
    return IBSRecord(timestamp: timestamp.nearest(5, .minute), bristolScale: bristolScale, tags: viewModel.tags, color: color, pressure: pressure, smell: smell, evacuation: evacuation, dryness: dryness, wetness: wetness)
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      bristolScale != nil
  }

  var body: some View {
    FormView("Bowel Movement", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        bristolTypePicker
      }

      Section {
        evacuationPicker
        smellPicker
      }

      Section {
        colorPicker
      }

      Section {
        ScaleSlider($pressure, "Pressure", descriptions: Scales.pressureDescriptions)
        ScaleSlider($wetness, "Wetness", descriptions: Scales.wetnessDescriptions)
        ScaleSlider($dryness, "Dryness", descriptions: Scales.drynessDescriptions)
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, onEditingChanged: viewModel.showTagSuggestions, scroller: scroller)
        .scrollID(.info)

      SaveButtonSection(name: "Bowel Movement", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp, scroller: scroller)
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

  private var bristolTypePicker: some View {
    VStack {
      Text(bristolScaleDescription)
        .foregroundColor(ColorCodedContent.bristolColor(for: bristolScale))
      HStack {
        ForEach(Range(0...7)) { scale in
          if let scale = BristolType(rawValue: Int(scale)) {
            BristolView(scale: scale, frameSize: 29.5, foregroundColor: foregroundColor(for: scale))
              .frame(maxWidth: .infinity)
              .onTapGesture { bristolScale = scale }
          }
        }
      }
    }
    .listRowBackground(color == .none ? Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0)) : color.color)
  }

  private var colorPicker: some View {
    VStack {
      Text(color == .none ? "Color" : color.rawValue.capitalized)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
      HStack {
        ForEach(BMColor.allCases, id: \.self) { color in
            if color != .none {
              Circle()
                .strokeBorder(Color.secondary, lineWidth: 1)
                .background(Circle().fill(color.color))
                .scaledToFit()
                .accessibility(identifier: color.rawValue)
                .onTapGesture {
                  self.color = color
                }
            }
        }
        ZStack {
          Color.white
            .scaledToFit()
            .opacity(0)
          Image(systemName: "xmark.circle")
            .foregroundColor(.secondary)
            .scaledToFit()
            .onTapGesture {
              self.color = .none
            }
        }

      }
    }
    .listRowBackground(color == .none ? Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0)) : color.color)
  }

  private var evacuationPicker: some View {
    VStack {
      Text("\(BMEvacuation.descriptions[evacuation]?.capitalized ?? "") Evacuation")
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    VStack {
      Text("Smell")
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
      Picker("Smell", selection: $smell) {
        ForEach(BMSmell.allCases, id: \.self) { smell in
          Text(smell.rawValue.capitalized)
            .tag(smell)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private func foregroundColor(for scale: BristolType?) -> Color? {
    scale == bristolScale ? nil : .secondary
  }

  private func calcSuggestedTags() {
    DispatchQueue.main.async {
      suggestedTags = appState.tags(for: .bm)
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

struct BMFormView_Previews: PreviewProvider {
  static var previews: some View {
    BMFormView()
      .environmentObject(IBSData())
  }
}
