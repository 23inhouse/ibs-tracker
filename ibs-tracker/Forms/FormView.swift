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

  init(viewModel: FormViewModel, editableRecord: IBSRecordType? = nil, @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    self._viewModel = ObservedObject(initialValue: viewModel)
    self.content = content
    self.editableRecord = editableRecord
  }

  var body: some View {
    ScrollViewReader { scroller in
      Form {
        DatePickerSectionView(timestamp: $viewModel.timestamp, isValid: $viewModel.isValidTimestamp, initial: editableRecord?.timestamp)

        content(scroller)

        DatePickerSectionView(timestamp: $viewModel.timestamp, isValid: $viewModel.isValidTimestamp, initial: editableRecord?.timestamp)
      }
      .onAppear() {
        viewModel.initializeTimestamp()
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
}

struct FormView_Previews: PreviewProvider {
  static var previews: some View {
    FormView(viewModel: FormViewModel()) { _ in
      FoodFormView()
    }
    .environmentObject(IBSData())
  }
}
