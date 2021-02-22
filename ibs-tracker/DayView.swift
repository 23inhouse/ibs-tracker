//
//  DayView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct DayView: View {
  @EnvironmentObject private var appState: IBSData
  @State private var date: Date = Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date()

  var records: [IBSRecord] {
    let dayRecord = appState.dayRecords
      .first { $0.date.string(for: "YYYY-MM-DD") == date.string(for: "YYYY-MM-DD") }

    return dayRecord?.ibsRecords ?? []
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(records, id: \.self) { record in
          ItemTypeDayRowView(record: record)
            .listRowInsets(EdgeInsets())
        }
      }
      .id(UUID())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(dateString())
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: prevDay) {
            Image(systemName: "chevron.left")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: nextDay) {
            Image(systemName: "chevron.right")
          }
        }
      }
      .gesture(swipeGesture)
      .transition(.move(edge: .bottom))
    }
  }

  var swipeGesture: _EndedGesture<DragGesture> {
    DragGesture(minimumDistance: 20)
      .onEnded {
        let start = $0.startLocation
        let end = $0.location
        let halfScreenWidth: CGFloat = UIScreen.halfMainWidth

        if start.x < end.x && start.x < halfScreenWidth  {
          self.changeDay(by: -1)
        } else if start.x > end.x && start.x > halfScreenWidth {
          self.changeDay(by: 1)
        }
      }
  }
}

private extension DayView {
  func changeDay(by days: Int) {
    date = Calendar.current.date(byAdding: .day, value: days, to: self.date) ?? date
  }

  func dateString() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
  }

  func prevDay() {
    changeDay(by: -1)
  }

  func nextDay() {
    changeDay(by: 1)
  }
}

struct DayView_Previews: PreviewProvider {
  static var previews: some View {
    DayView()
      .environmentObject(IBSData())
  }
}
