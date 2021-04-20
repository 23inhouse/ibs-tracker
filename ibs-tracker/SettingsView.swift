//
//  SettingsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @State private var url = ""
  @State private var truncate = false
  @State private var includeFood = false

  @State private var isImporting = false
  @State private var isExportingJSON = false
  @State private var isExportingPDF = false
  @State private var isReseting = false

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
          resetDataSection
        }

        Section {
          importSection
        }

        Section {
          exportJSONButton
            .sheet(isPresented: $isSharingJSON) {
              UIKitBridge.SwiftUIActivityViewController(activityItems: $sharedItems)
            }
        }

        Section {
          Toggle("Include food", isOn: $includeFood)
          LazyNavigationLink(destination: PDFReportView(includeFood: $includeFood)) {
            Text("View PDF report \(includeFood ? "with food" : "")")
          }
          exportPDFButton
            .sheet(isPresented: $isSharingPDF) {
              UIKitBridge.SwiftUIActivityViewController(activityItems: $sharedItems)
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
      .gesture(DragGesture().onChanged({ _ in endEditing(true) }))
    }
  }

  private var exportJSONButton: some View {
    ZStack {
      loadingButton($isExportingJSON, text: "Export JSON", icon: "square.and.arrow.up") {
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
      loadingButton($isExportingPDF, text: "Export PDF", icon: "square.and.arrow.up") {
        isExportingPDF = true
        DispatchQueue.main.async {
          let pdf = PDF(recordsByDay: appState.recordsByDay, includeFood: includeFood)
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
        .foregroundColor(url.isEmpty ? .secondary : .primary)
        .disabled(url.isEmpty)
      loadingButton($isImporting, text: "Import JSON from URL", icon: "square.and.arrow.down") {
        isImporting = true
        url.fetchJSON() { data in
          AppDB.current.importJSON(data, truncate: truncate)
          DispatchQueue.main.async {
            appState.reloadRecordsFromSQL()
            isImporting = false
          }
        }
      }
      .disabled(url.isEmpty)
    }
  }

  private var resetDataSection: some View {
    loadingButton($isReseting, text: "Reset all data", icon: "square") {
      isReseting = true
    }
    .alert(isPresented: $isReseting) {
      deleteAlert {
        DispatchQueue.main.async {
          AppDB.current.resetRecords()
          DispatchQueue.main.async {
            appState.reloadRecordsFromSQL()
          }
          isReseting = false
        }
      }
    }
  }

  private func deleteAlert(action: @escaping () -> Void) -> Alert {
    Alert(
      title: Text("Are you sure?"),
      message: Text("You will lose all you data!"),
      primaryButton: .destructive(Text("Reset all"), action: action),
      secondaryButton: .cancel()
    )
  }

  private func loadingButton(_ loading: Binding<Bool>, text: String, icon: String, action: @escaping () -> Void) -> some View {
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
