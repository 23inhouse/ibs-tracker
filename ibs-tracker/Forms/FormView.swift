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
  private let content: Content

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  init(viewModel: FormViewModel, editableRecord: IBSRecordType? = nil, @ViewBuilder content: @escaping () -> Content) {
    self._viewModel = ObservedObject(initialValue: viewModel)
    self.content = content()
    self.editableRecord = editableRecord
  }

  var body: some View {
    Form {
      content

      DatePickerSectionView(timestamp: $viewModel.timestamp, isValidTimestamp: $viewModel.isValidTimestamp)
    }
    .onAppear() {
      viewModel.setCurrentTimestamp()
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      DeleteRecordToolbarItem(editMode: editMode, showAlert: $viewModel.showAlert)
    }
    .alert(delete: editableRecord, appState: appState, isPresented: $viewModel.showAlert) {
      DispatchQueue.main.async {
        appState.tabSelection = .day
        presentation.wrappedValue.dismiss()
      }
    }
    .gesture(DragGesture().onChanged { _ in endEditing(true) })
  }
}

struct FormView_Previews: PreviewProvider {
  static var previews: some View {
    FormView(viewModel: FormViewModel()) {
      FoodFormView()
    }
    .environmentObject(IBSData())
  }
}
