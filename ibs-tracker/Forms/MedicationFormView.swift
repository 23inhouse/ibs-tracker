//
//  MedicationFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/3/21.
//

import SwiftUI

struct MedicationFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var name: String = ""
  @State private var isEditingName: Bool = false
  @State private var nameIsCompleted: Bool = false
  @State private var medicationTypes: [MedicationType] = []
  @State private var recentMedications: [IBSRecord] = []
  @State private var recentMedicationSelection: IBSRecord?

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

  init(for medicationRecord: MedicationRecord? = nil) {
    guard let record = medicationRecord else { return }
    self.editableRecord = medicationRecord
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._name = State(initialValue: record.text ?? "")
    self._medicationTypes = State(initialValue: record.medicationType ?? [])
  }

  private var availableMedicationTypes = MedicationType.allCases.filter { $0 != .none }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var editableMedicationTypes: [MedicationType] { medicationTypes }

  private var recentMedicationPlaceholder: String {
    name.isEmpty && viewModel.tags.isEmpty ? "Choose from recent medication" : "Replace with recent medication"
  }

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(medication: name, type: medicationTypes, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags)
  }

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      name.isNotEmpty && medicationTypes.isNotEmpty
  }

  var body: some View {
    FormView("Medication", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        if recentMedications.isNotEmpty {
          recentMedicationSection
        }
      }

      Section {
        UIKitBridge.SwiftUITextField("Medication name. e.g. Metamucil", text: $name, onEditingChanged: editName, onCommit: commitName)
          .onTapGesture {
            scroller.scrollTo(id: .medication)
          }
      }
      .scrollID(.medication)

      Section {
        List {
          ForEach(availableMedicationTypes, id: \.self) { medicationType in
            Toggle(medicationType.rawValue.capitalized, isOn: Binding(
              get: { medicationTypes.contains(medicationType) },
              set: { medicationTypes.toggle(on: $0, element: medicationType) }
            ))
          }
        }
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, onEditingChanged: viewModel.showTagSuggestions, scroller: scroller)
        .scrollID(.info)

      SaveButtonSection(name: "Medication", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp, scroller: scroller)
    }
    .onAppear {
      calcRecentMedications()
      calcSuggestedTags()
    }
    .onChange(of: [showAllTags, isEditingName, nameIsCompleted]) { _ in
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.tags, [viewModel.newTag]]) { _ in
      calcSuggestedTags()
    }
  }

  private var recentMedicationSection: some View {
    Section {
      Picker(recentMedicationPlaceholder, selection: $recentMedicationSelection) {
        ForEach(recentMedications, id: \.self) { record in
          VStack(alignment: .leading) {
            Text(record.text ?? "")
            TagCloudView(tags: record.tags)
          }.tag(record as IBSRecord?)
        }
      }
      .onChange(of: recentMedicationSelection) { record in
        guard let record = record else { return }
        name = record.text ?? ""
        viewModel.tags = record.tags
        medicationTypes = record.medicationType ?? [.none]
        recentMedicationSelection = nil
      }
    }
  }

  private func commitName() {
    endEditing(true)
    isEditingName = false
    nameIsCompleted = true
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func editName(_ isEditing: Bool) {
    isEditingName = isEditing
  }

  private func calcRecentMedications() {
    DispatchQueue.main.async {
      recentMedications = appState.recentRecords(of: .medication)
    }
  }

  private func calcSuggestedTags() {
    guard showAllTags || !isEditingName else {
      suggestedTags = []
      return
    }

    DispatchQueue.main.async {
      suggestedTags = appState.tags(for: .medication)
        .filter {
          let availableTag = $0.lowercased()
          return
            !viewModel.tags.contains($0) &&
            (
              showAllTags ||
                availableTag.contains(viewModel.newTag.lowercased()) ||
                (
                  nameIsCompleted &&
                    name.split(separator: " ").filter {
                      let word = String($0.lowercased())
                      return
                        viewModel.tags.filter { $0.lowercased().contains(word) }.isEmpty &&
                        (availableTag.contains(word) || word.contains(availableTag))
                    }.isNotEmpty
                )
            )
        }
    }
  }
}

struct MedicationFormView_Previews: PreviewProvider {
  static var previews: some View {
    MedicationFormView()
      .environmentObject(IBSData())
  }
}
