//
//  DayRecordScales.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 5/5/21.
//

import Foundation

struct DayRecordScales {
  /**
   Calculate the scale based on the time interval
   [7:30 pm, 8:30pm, 9.30pm, 10:30pm, 11:30pm] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  static func calcMealTooLate(from timestamp: Date) -> Scales? {
    let adjustedTimestamp = IBSData.timeShiftedDate(for: timestamp)
    let adjustedHour = Calendar.current.component(.hour, from: adjustedTimestamp)
    let adjustedSevenPM = 19 - IBSData.numberOfHoursInMorningIncludedInPreviousDay

    let scale = adjustedHour - adjustedSevenPM
    guard scale > 0 else { return nil }
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }

  /**
   Calculate the scale based on the time interval
   [1.0 hours, 1.5 hours, 2.0 hours, 2.5 hours, 3.0 hours] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  static func calcMealTooLong(from duration: TimeInterval) -> Scales? {
    let hour: Double = 60 * 60
    let scale = Int(round((duration - (1.0 * hour)) / hour * 2))
    guard scale > 0 else { return nil }
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }

  /**
   Calculate the scale based on the time interval
   [3.5 hours, 3.0 hours, 2.5 hours, 2.0 hours, 1.5 hours] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  static func calcMealTooSoon(from duration: TimeInterval) -> Scales {
    let hour: Double = 60 * 60
    let scale = 4 - Int(round((duration - (1.75 * hour)) / hour * 2))
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }
}
