//
//  DayView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct DayView: View {
  @EnvironmentObject private var appState: IBSData

  private var date: Date { appState.activeDate }

  private var isShowingToday: Bool {
    let calendar = Calendar.current

    let displayDate = calendar.dateComponents([.year, .month, .day], from: appState.activeDate)
    let currentDate = calendar.dateComponents([.year, .month, .day], from: IBSData.currentDate())

    return displayDate == currentDate
  }

  private var records: [IBSRecord] {
    let dayRecord = appState.dayRecords
      .first { $0.date.string(for: "YYYY-MM-DD") == date.string(for: "YYYY-MM-DD") }

    return dayRecord?.ibsRecords ?? []
  }

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(records, id: \.self) { record in
            ItemTypeDayRowView(record: record)
            Divider()
              .padding(.horizontal, 10)
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          dateTitle
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
    }
    .gesture(swipeGesture)
  }

  private var dateTitle: some View {
    let smallScreenSize = UIScreen.mainWidth < 375
    return HStack(spacing: 5) {
      DatePicker("Current date", selection: $appState.activeDate, displayedComponents: .date)
        .datePickerStyle(CompactDatePickerStyle())
        .labelsHidden()
        .frame(width: 120, alignment: .trailing)
      Text(date.string(for: smallScreenSize ? "EEE" : "EEEE"))
        .frame(width: smallScreenSize ? 40 : 90)
      Button(action: changeDayToToday) {
        Image(systemName: "calendar.circle")
          .resizable()
          .frame(width: 21, height: 21)
          .padding(5)
      }
      .disabled(isShowingToday)
    }
  }

  private var swipeGesture: _EndedGesture<DragGesture> {
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
    appState.activeDate = Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
  }

  func changeDayToToday() {
    withAnimation {
      appState.activeDate = IBSData.currentDate()
    }
  }

  func dateString() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
  }

  func prevDay() {
    withAnimation {
      changeDay(by: -1)
    }
  }

  func nextDay() {
    withAnimation {
      changeDay(by: 1)
    }
  }
}

struct DayView_Previews: PreviewProvider {
  static var previews: some View {
    DayView()
      .environmentObject(IBSData())
  }
}
