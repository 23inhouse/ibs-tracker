//
//  ContentView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/1/21.
//

import SwiftUI
import PureSwiftUI

struct ContentView: View {
  @EnvironmentObject private var appState: IBSData
  var body: some View {
    mainTabView()
  }
}

private extension ContentView {
  func mainTabView() -> some View {
    TabView(selection: $appState.tabSelection) {
      SettingsView()
        .tabItem {
          Image(systemName: "gearshape")
          Text("Settings")
        }
        .tag(Tabs.settings)
      DayView()
        .tabItem {
          Image(systemName: "equal.square")
          Text("Today")
        }
        .tag(Tabs.day)
      ActionGridView()
        .tabItem {
          Image(systemName: "plus.circle")
          Text("Add")
        }
        .tag(Tabs.add)
      ReportView()
        .tabItem {
          Image(systemName: "chart.bar")
          Text("Report")
        }
        .tag(Tabs.report)
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Search")
        }
        .tag(Tabs.search)
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
