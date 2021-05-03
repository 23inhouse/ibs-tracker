//
//  DayRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

struct DayRecord: Identifiable {
  var id = UUID()
  private(set) var date: Date
  private(set) var records: [IBSRecord]
  private let unfilteredRecords: [IBSRecord]

  init(date: Date, records: [IBSRecord], unfilteredRecords: [IBSRecord] = []) {
    self.date = date
    self.records = records
    self.unfilteredRecords = unfilteredRecords.isNotEmpty ? unfilteredRecords : records

    calcMetaRecords()
  }
}

private extension DayRecord {
  mutating func calcMetaRecords() {
    var mutatableRecords = Array(records.reversed()) // return earliest first
    let metaBMRecords = calcBMMetaRecords(records: &mutatableRecords)
    let metaFoodRecords = calcFoodMetaRecords(records: &mutatableRecords)
    calcFoodMetaTags(records: &mutatableRecords)

    records = (metaBMRecords + mutatableRecords + metaFoodRecords)
      .sorted { $0.timestamp > $1.timestamp } // return latest first
  }

  func calcBMMetaRecords(records: inout [IBSRecord]) -> [IBSRecord] {
    guard date != IBSData.timeShiftedDate() else { return [] }

    let constipationTimestamp = adjustedTimestamp(at: 1)
    let unfilteredRecordsBMRecords = unfilteredRecords.filter { $0.type == .bm }
    let count = unfilteredRecordsBMRecords.count

    guard count > 0 else {
      return [IBSRecord(timestamp: constipationTimestamp, bristolScale: .b0)]
    }

    var numberOfBMs = 0
    for (i, record) in records.enumerated() {
      guard record.type == .bm else { continue }

      records[i].numberOfBMs = UInt(count - numberOfBMs)
      numberOfBMs += 1
    }

    return []
  }

  func calcFoodMetaRecords(records: inout [IBSRecord]) -> [IBSRecord] {
    let foodRecords = records.filter(\.isNotMedicinalFood)
    let count = foodRecords.count

    guard count > 0 else { return [] }

    let fittableLabels: [MealType] = [.breakfast, .lunch, .dinner, .snack]
    let recordTags = fitTags(labels: fittableLabels, records: records, taggable: \.isNotMedicinalFood)

    var lastTimestamp = date
    var currentTimestamp = date
    var currentMealType: MealType? = nil
    var currentIndex: Int? = nil
    for (i, mealType) in recordTags.enumerated() {
      records[i].mealType = mealType

      guard mealType != nil else { continue }

      let record = records[i]

      records[i].mealTooLate = calcMealTooLateScale(from: record.timestamp)

      if let currentMealType = currentMealType {
        if mealType != currentMealType {
          let cleansingDuration = record.timestamp.timeIntervalSince(lastTimestamp)
          records[i].mealTooSoon = calcMealTooSoonScale(from: cleansingDuration)
        } else {
          let mealDuration = record.timestamp.timeIntervalSince(currentTimestamp)
          records[i].mealTooLong = calcMealTooLongScale(from: mealDuration)
        }
      }

      if mealType != currentMealType {
        records[i].mealStart = true
        records[i].mealEnd = true
        currentTimestamp = record.timestamp
        currentIndex = i
      } else {
        lastTimestamp = record.timestamp
        records[i].mealEnd = true
        if let currentIndex = currentIndex {
          records[currentIndex].mealEnd = nil
        }
        currentIndex = i
      }
      currentMealType = mealType
    }

    return []
  }

  func calcFoodMetaTags(records: inout [IBSRecord]) {
    for (i, record) in records.enumerated() {
      let metaTags: [String]
      switch record.type {
      case .ache:
        metaTags = record.calcAcheMetaTags()
      case .bm:
        metaTags = record.calcBMMetaTags()
      case .food:
        metaTags = record.calcFoodMetaTags()
      case .gut:
        metaTags = record.calcGutMetaTags()
      case .medication:
        metaTags = record.calcMedicationMetaTags()
      case .mood:
        metaTags = record.calcMoodMetaTags()
      case .note:
        metaTags = record.calcNoteMetaTags()
      case .skin:
        metaTags = record.calcSkinMetaTags()
      case .weight:
        metaTags = record.calcWeightMetaTags()
      case .none:
        metaTags = record.tags
      }
      records[i].metaTags = metaTags
    }
  }

  /**
   Calculate the scale based on the time interval
   [7:30 pm, 8:30pm, 9.30pm, 10:30pm, 11:30pm] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  func calcMealTooLateScale(from timestamp: Date) -> Scales? {
    let adjustedTimestamp = IBSData.timeShiftedDate(for: timestamp)
    let adjustedHour = Calendar.current.component(.hour, from: adjustedTimestamp)
    let adjustedSevenPM = 19 - IBSData.numberOfHoursInMorningIncludedInPreviousDay

    let scale = adjustedHour - adjustedSevenPM
    guard scale > 0 else { return nil }
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }

  /**
   Calculate the scale based on the time interval
   [1.5 hours, 2.0 hours, 2.5 hours, 3.0 hours, 3.5 hours] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  func calcMealTooLongScale(from duration: TimeInterval) -> Scales? {
    let hour: Double = 60 * 60
    let scale = Int(round((duration - (1.5 * hour)) / hour * 2))
    guard scale > 0 else { return nil }
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }

  /**
   Calculate the scale based on the time interval
   [3.5 hours, 3.0 hours, 2.5 hours, 2.0 hours, 1.5 hours] -> [.zero, .mild, .moderate, .severe, .extreme]
   */
  func calcMealTooSoonScale(from duration: TimeInterval) -> Scales {
    let hour: Double = 60 * 60
    let scale = 4 - Int(round((duration - (1.75 * hour)) / hour * 2))
    return Scales(rawValue: scale > 0 ? scale < 4 ? scale : 4 : 0)!
  }

  func fitTags(labels: [MealType], records: [IBSRecord], taggable: (IBSRecord) -> Bool) -> [MealType?] {
    let timestamps = records.filter(taggable).map(\.timestamp)
    guard timestamps.isNotEmpty else { return [] }

    let points: [Vector?] = records.map { record in
      guard taggable(record) else { return nil }
      let interval = record.timestamp.timeIntervalSince(date)
      return Vector([Double(interval)])
    }

    let convergeDistance: Double = 300 // 5 minutes (distance is measured in seconds)
    let kmm = KMeans<MealType>(labels: labels)
    let centers = kmm.calcCenters(on: date, for: timestamps, labels: labels)
    let trainingPoints = points.compactMap { $0 }
    kmm.train(points: trainingPoints, convergeDistance: convergeDistance, towards: centers)
    kmm.sortCenters()

    return kmm.fit(points)
  }

  func adjustedTimestamp(at adjustment: Int) -> Date {
    let hourOfDay = IBSData.numberOfHoursInMorningIncludedInPreviousDay + adjustment
    let interval = Double(hourOfDay * 60 * 60)
    return date.addingTimeInterval(interval)
  }
}
