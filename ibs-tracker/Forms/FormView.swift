//
//  FormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 27/2/21.
//

import SwiftUI

struct FormView<Content: View>: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @ObservedObject private var viewModel: FormViewModel
  private let content: (ScrollViewProxy) -> Content

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private let title: String

  init(_ title: String, viewModel: FormViewModel, editableRecord: IBSRecordType? = nil, @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    self._viewModel = ObservedObject(initialValue: viewModel)
    self.content = content
    self.editableRecord = editableRecord
    self.title = editableRecord != nil ? "Edit \(title)" : "Add \(title)"
  }

  var body: some View {
    ScrollViewReader { scroller in
      Form {
        DatePickerSectionView(timestamp: $viewModel.timestamp, isValid: $viewModel.isValidTimestamp)

        content(scroller)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(title)
        }
      }
      .onAppear() {
        viewModel.initializeTimestamp()
        guard !editMode else { return }
        DispatchQueue.main.async {
          viewModel.isValidTimestamp = isValid(timestamp: viewModel.timestamp)
        }
      }
      .onChange(of: viewModel.timestamp) { value in
        viewModel.timestamp = value
        DispatchQueue.main.async {
          viewModel.isValidTimestamp = isValid(timestamp: value)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        DeleteRecordToolbarItem(editMode: editMode, showAlert: $viewModel.showAlert)
      }
      .alert(isPresented: $viewModel.showAlert) {
        deleteAlert {
          DispatchQueue.main.async { appState.tabSelection = .day }
          presentation.dismiss(animation: .none)

          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
              guard let editableRecord = editableRecord else { return }
              try editableRecord.deleteSQL(into: AppDB.current)
              withAnimation { appState.reloadRecordsFromSQL() }
            } catch {
              print("Error: \(error)")
            }
          }
        }
      }
      .gesture(DragGesture().onChanged { _ in endEditing(true) })
    }
  }

  private func deleteAlert(action: @escaping () -> Void) -> Alert {
    Alert(
      title: Text("Are you sure?"),
      message: Text("This will delete the item"),
      primaryButton: .destructive(Text("OK"), action: action),
      secondaryButton: .cancel()
    )
  }

  private func isValid(timestamp: Date?) -> Bool {
    guard let timestamp = timestamp else { return false }
    guard timestamp != editableRecord?.timestamp else { return true }

    return appState.isAvailable(timestamp: timestamp)
  }
}

struct FormView_Previews: PreviewProvider {
  static var previews: some View {
    FormView("Meal", viewModel: FormViewModel()) { _ in
      FoodFormView()
    }
    .environmentObject(IBSData())
  }
}
