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
          Text("Day")
        }
      WeekView()
        .tabItem {
          Image(systemName: "chart.bar")
          Text("Week")
        }
      ActionGridView()
        .tabItem {
          Image(systemName: "plus.circle")
          Text("Add")
        }
      MonthView()
        .tabItem {
          Image(systemName: "square.grid.2x2")
          Text("Month")
        }
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Search")
        }
    }
  }
}

struct MonthView: View {
  var body: some View {
    NavigationView {
      Text("Month")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text("Weeks of ...")
          }
        }
    }
  }
}

struct WeekView: View {
  var body: some View {
    NavigationView {
      Text("Week")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text("Week of ...")
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
