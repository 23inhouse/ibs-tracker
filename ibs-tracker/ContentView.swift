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
          Image(systemName: "slider.horizontal.below.rectangle")
          Text("Day")
        }
        .tag(Tabs.day)
      ActionGridView()
        .tabItem {
          Image(systemName: "plus.circle")
          Text("Add")
        }
        .tag(Tabs.add)
      ChartView()
        .tabItem {
          Image(systemName: "chart.bar.doc.horizontal")
          Text("Chart")
        }
        .tag(Tabs.chart)
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Search")
        }
        .tag(Tabs.search)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(IBSData())
  }
}
