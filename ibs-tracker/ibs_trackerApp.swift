//
//  ibs_trackerApp.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/1/21.
//

import SwiftUI

@main
struct ibs_trackerApp: App {
  @EnvironmentObject private var appState: IBSData

  let loadApp: Bool = {
    guard !ibs_trackerApp.isTestRunning() else {
      // If we're running tests, our intent is to do nothing
      // Otherwise having the app running at the same time
      // makes debugging more difficult
      // * This will probably have to change for the UITests to work
      print("App is in Test mode")
      return false
    }

    return true
  }()

  var body: some Scene {
    WindowGroup {
      if loadApp {
        ContentView()
          .environmentObject(IBSData.current)
      } else {
        ZStack {}
      }
    }
  }
}

protocol Testable {
  static func isTestRunning() -> Bool
}

extension ibs_trackerApp: Testable {
  static func isTestRunning() -> Bool {
    if let _ = NSClassFromString("XCTest") {
      return true
    }

    return false
  }
}
