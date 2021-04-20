//
//  PDFReportView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/3/21.
//

import SwiftUI

struct PDFReportView: View {
  @EnvironmentObject private var appState: IBSData
  @Binding var includeFood: Bool

  init(includeFood: Binding<Bool> = Binding.constant(true)) {
    self._includeFood = includeFood
  }

  var url: URL? {
    let pdf = PDF(recordsByDay: appState.recordsByDay, includeFood: includeFood)
    do {
      return try PDF.encode(pdf).url(path: "report.pdf")
    } catch {
      print("Error: \(error)")
      return nil
    }
  }

  var body: some View {
    UIKitBridge.SwiftUIPDFView(url)
  }
}
