//
//  SaveButtonSection.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct SaveButtonSection: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  var name: String
  var record: IBSRecord?
  var isValidTimestamp: Bool = true
  var editMode: Bool = false
  var editTimestamp: Date?

  var body: some View {
    Section {
      Button(action: {
        insertOrUpdate {
          DispatchQueue.main.async {
            appState.tabSelection = .day
            guard let timestamp = record?.timestamp else { return }
            appState.activeDate = IBSData.currentDate(for: timestamp)
          }
          presentation.dismiss(animation: .none)
        }
      }) {
        Text(editMode ? "Update \(name)" : "Add \(name)")
          .frame(maxWidth: .infinity)
      }
    }
    .modifierIf(isValidTimestamp) {
      $0
        .listRowBackground(Color.blue)
        .foregroundColor(.white)
    }
    .modifierIf(!isValidTimestamp) {
      $0
        .listRowBackground(Color.secondary)
        .opacity(0.8)
        .foregroundColor(Color(red: 1, green: 0, blue: 0, opacity: 0.333))
    }
    .disabled(!isValidTimestamp)
  }

  private func insertOrUpdate(completionHandler: @escaping () -> Void) {
    completionHandler()

    DispatchQueue.global(qos: .userInteractive).async {
      do {
        guard let record = record else { return }

        if let editTimestamp = editTimestamp {
          try record.updateSQL(into: AppDB.current, timestamp: editTimestamp)
        } else {
          try record.insertSQL(into: AppDB.current)
        }
        DispatchQueue.main.async {
          withAnimation { appState.reloadRecordsFromSQL() }
        }
      } catch {
        print("Error: \(error)")
      }
    }
  }
}

struct SaveButtonSection_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SaveButtonSection(name: "Meal")
        .environmentObject(IBSData())
    }
  }
}
