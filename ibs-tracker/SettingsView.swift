//
//  SettingsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appState: IBSData

  @State private var url = "https://gist.githubusercontent.com/23inhouse/d66aeb52ce44fdf61ab7f36f89509ec3/raw/eebf2164622a65ff561005d851856aecaa520a4d/import.json"
  @State private var truncate = false

  @State private var isImporting = false
  @State private var isExporting = false

  private let activityViewController = UIKitBridge.SwiftUIActivityViewController()

  var body: some View {
    NavigationView {
      Form {
        importSection
        exportSection
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Settings")
        }
      }
    }
  }

  private var exportSection: some View {
    Section {
      ZStack {
        lodingButton($isExporting, text: "Export JSON", icon: "square.and.arrow.up") {
          isExporting = true
          DispatchQueue.main.async {
            if let jsonFileUrl = DataSet.jsonFileUrl() {
              self.activityViewController.share(any: jsonFileUrl)
            }
            isExporting = false
          }
        }
        activityViewController
      }.id(UUID())
    }
  }

  private var importSection: some View {
    Section {
      TextField("JSON URL with the DataSet", text: $url)
      Toggle("Delete existing records", isOn: $truncate)
      lodingButton($isImporting, text: "Import JSON from URL", icon: "square.and.arrow.down") {
        isImporting = true
        url.fetchJSON() { data in
          AppDB.current.importJSON(data, truncate: truncate)
          DispatchQueue.main.async {
            appState.reloadRecordsFromSQL()
            isImporting = false
          }
        }
      }
    }
  }

  private func lodingButton(_ loading: Binding<Bool>, text: String, icon: String, action: @escaping () -> Void) -> some View {
    Group {
      if loading.wrappedValue {
        ProgressView()
          .frame(maxWidth: .infinity)
          .progressViewStyle(CircularProgressViewStyle())
      } else {
        Button(action: action) {
          HStack {
            Image(systemName: icon)
            Text(text)
            Spacer()
          }
        }
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
