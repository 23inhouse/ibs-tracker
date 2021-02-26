//
//  DatePickerSectionView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct DatePickerSectionView: View {
  @EnvironmentObject private var appState: IBSData

  @Binding var timestamp: Date?
  @Binding var isValidTimestamp: Bool

  var body: some View {
    Section {
      UIKitBridge.SwiftUIDatePicker(selection: $timestamp, range: nil, minuteInterval: 5)
        .onChange(of: timestamp) { value in
          self.timestamp = value
          self.isValidTimestamp = isValid(timestamp: timestamp)
        }
    }
    .modifierIf(!isValidTimestamp) {
      $0
        .listRowBackground(Color(red: 1, green: 0, blue: 0, opacity: 0.333))
        .opacity(0.8)
    }
  }

  private func isValid(timestamp: Date?) -> Bool {
    guard let timestamp = timestamp else { return false }

    return appState.isAvailable(timestamp: timestamp)
  }
}

struct DatePickerSectionView_Previews: PreviewProvider {
  static var previews: some View {
    DatePickerSectionView(timestamp: Binding.constant(nil), isValidTimestamp: Binding.constant(false))
      .environmentObject(IBSData())
  }
}
