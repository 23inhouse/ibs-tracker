//
//  View+AlertDeleteRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

extension View {
  func alert(delete record: IBSRecord?, appState: IBSData, isPresented: Binding<Bool>, completionHandler: @escaping () -> Void) -> some View {
    alert(isPresented: isPresented) {
      Alert(
        title: Text("Are you sure?"),
        message: Text("This will delete the item"),
        primaryButton: .default (Text("OK")) {
          completionHandler()

          DispatchQueue.global(qos: .utility).async {
            do {
              guard let record = record else { return }
              try record.deleteSQL(into: AppDB.current)
              DispatchQueue.main.async {
                appState.reloadRecordsFromSQL()
              }
            } catch {
              print("Error: \(error)")
            }
          }
        },
        secondaryButton: .cancel()
      )
    }
  }
}
