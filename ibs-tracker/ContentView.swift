//
//  ContentView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/1/21.
//

import SwiftUI
import PureSwiftUI

struct ContentView: View {
  var body: some View {
    mainTabView()
  }
}

private extension ContentView {
  func mainTabView() -> some View {
    TabView {
      DayView()
        .tabItem {
          Image(systemName: "equal.square")
          Text("Today")
        }
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Search")
        }
      ActionGridView()
        .tabItem {
          Image(systemName: "plus.circle")
          Text("Add")
        }
      ReportView()
        .tabItem {
          Image(systemName: "chart.bar")
          Text("Report")
        }
      SettingsView()
        .tabItem {
          Image(systemName: "gearshape")
          Text("Settings")
        }
    }
  }
}

struct ReportView: View {
  var body: some View {
    NavigationView {
      Text("Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text("Report")
          }
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(IBSData())
  }
}
