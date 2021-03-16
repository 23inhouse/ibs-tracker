//
//  DeleteRecordToolbarItem.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct DeleteRecordToolbarItem: ToolbarContent {
  var editMode: Bool
  @Binding var showAlert: Bool

  var body: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      if editMode {
        Button(action: {
          showAlert = true
        }, label: {
          Image(systemName: "trash")
        })
        .padding(5)
      } else {
        EmptyView()
      }
    }
  }
}
