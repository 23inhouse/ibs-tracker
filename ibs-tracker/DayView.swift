//
//  DayView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct DayView: View {
  @EnvironmentObject private var appState: IBSData

  private var date: Date { appState.currentDate }

  private var isShowingToday: Bool {
    let calendar = Calendar.current

    let displayDate = calendar.dateComponents([.year, .month, .day], from: appState.currentDate)
    let currentDate = calendar.dateComponents([.year, .month, .day], from: IBSData.currentDate())

    return displayDate == currentDate
  }

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
          HStack {
            DatePicker("Current date", selection: $appState.currentDate, displayedComponents: .date)
              .datePickerStyle(CompactDatePickerStyle())
              .labelsHidden()
            Button(action: changeDayToToday) {
              Image(systemName: "calendar.circle")
                .padding(5)
            }
            .disabled(isShowingToday)
          }
          .frame(height: 150, alignment: .trailing)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: prevDay) {
            Image(systemName: "arrow.backward.circle")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: nextDay) {
            Image(systemName: "arrow.forward.circle")
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
          prevDay()
        } else if start.x > end.x && start.x > halfScreenWidth {
          nextDay()
        }
      }
  }
}

private extension DayView {
  func changeDay(by days: Int) {
    appState.currentDate = Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
  }

  func changeDayToToday() {
    appState.currentDate = IBSData.currentDate()
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
