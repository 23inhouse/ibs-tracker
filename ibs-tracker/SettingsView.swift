//
//  SettingsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appState: IBSData

  @State private var url = "https://gist.githubusercontent.com/23inhouse/d66aeb52ce44fdf61ab7f36f89509ec3/raw/545f344a9d9abd03391b9b33d8b62f5a7d3c3b7e/import.json"
  @State private var truncate = false
  @State private var includeFood = false

  @State private var isImporting = false
  @State private var isExportingJSON = false
  @State private var isExportingPDF = false

  @State private var isSharingJSON = false
  @State private var isSharingPDF = false
  @State private var sharedItems: [Any] = []

  private var isDisabled: Bool {
    isImporting || isExportingJSON || isExportingPDF
  }

  var body: some View {
    NavigationView {
      Form {
        Section {
          importSection
          exportJSONButton
            .sheet(isPresented: $isSharingJSON) {
              UIKitBridge.SwiftUIActivityViewController(activityItems: $sharedItems)
            }
        }

        Section {
          Toggle("Include food", isOn: $includeFood)
          exportPDFButton
            .sheet(isPresented: $isSharingPDF) {
              UIKitBridge.SwiftUIActivityViewController(activityItems: $sharedItems)
            }
          LazyNavigationLink(destination: PDFReportView(includeFood: $includeFood)) {
            Text("View PDF report \(includeFood ? "with food" : "")")
          }
        }
      }
      .disabled(isDisabled)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Settings")
        }
      }
    }
  }

  private var exportJSONButton: some View {
    ZStack {
      lodingButton($isExportingJSON, text: "Export JSON", icon: "square.and.arrow.up") {
        isExportingJSON = true
        DispatchQueue.main.async {
          if let jsonFileUrl = DataSet.jsonFileUrl() {
            isSharingJSON = true
            sharedItems = [jsonFileUrl]
          }
          isExportingJSON = false
        }
      }
    }.id(UUID())
  }

  private var exportPDFButton: some View {
    ZStack {
      lodingButton($isExportingPDF, text: "Export PDF", icon: "square.and.arrow.up") {
        isExportingPDF = true
        DispatchQueue.main.async {
          let pdf = PDF(dayRecords: appState.dayRecords, includeFood: includeFood)
          do {
            if let pdfFileUrl = try PDF.encode(pdf).url(path: "report.pdf") {
              isSharingPDF = true
              sharedItems = [pdfFileUrl]
            }
          } catch {
            print("Error: \(error)")
          }
          isExportingPDF = false
        }
      }
    }.id(UUID())
  }

  private var importSection: some View {
    Group {
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
