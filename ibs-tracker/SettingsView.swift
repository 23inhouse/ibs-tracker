//
//  SettingsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appState: IBSData

  @State private var url = "https://gist.githubusercontent.com/23inhouse/d66aeb52ce44fdf61ab7f36f89509ec3/raw/ed1d9225c257a889ffa80e3487cf48f79aca91b0/import.json"
  @State private var truncate = false

  @State private var isImporting = false

  let activityViewController = UIKitBridge.SwiftUIActivityViewController()
  private var jsonFileUrl: URL? = DataSet.jsonFileUrl()

  var body: some View {
    NavigationView {
      Form {
        importSection
        if jsonFileUrl != nil {
          exportSection
        }
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
        Button(action: {
          activityViewController.share(any: jsonFileUrl!)
        }) {
          HStack {
            Image(systemName:"square.and.arrow.up")
            Text("Export JSON")
            Spacer()
          }
        }
        activityViewController
      }
    }
  }

  private var importSection: some View {
    Section {
      TextField("JSON URL with the DataSet", text: $url)
      Toggle("Delete existing records", isOn: $truncate)
      if isImporting {
        ProgressView()
          .frame(maxWidth: .infinity)
          .progressViewStyle(CircularProgressViewStyle())
      } else {
        Button(action: {
          isImporting = true
          url.fetchJSON() { data in
            AppDB.current.importJSON(data, truncate: truncate)
            DispatchQueue.main.async {
              appState.reloadRecordsFromSQL()
              isImporting = false
            }
          }
        }) {
          HStack {
            Image(systemName:"square.and.arrow.down")
            Text("Import JSON from URL")
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
