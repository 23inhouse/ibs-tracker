//
//  ibs_trackerApp.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/1/21.
//

import SwiftUI

@main
struct ibs_trackerApp: App {
  @EnvironmentObject private var appState: AppState

  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(AppState())
    }
  }
}
