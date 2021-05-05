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

  init(date: Date, records: [IBSRecord], unfilteredRecords: [IBSRecord] = [], calculateMeta: Bool = true) {
    self.date = date
    self.records = records
    self.unfilteredRecords = unfilteredRecords.isNotEmpty ? unfilteredRecords : records

    if calculateMeta {
      calcMetaRecords()
    }
  }
}

private extension DayRecord {
  mutating func calcMetaRecords() {
    var mutatableRecords = Array(records.reversed()) // return earliest first
//    var mutatableRecords = records.sorted { $0.timestamp < $1.timestamp } // return earliest first
    let metaBMRecords = calcBMMetaRecords(records: &mutatableRecords)
    calcFoodMetaRecords(records: &mutatableRecords)
    calcMetaTags(records: &mutatableRecords)

    records = (metaBMRecords + mutatableRecords)
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

  func calcFoodMetaRecords(records: inout [IBSRecord]) {
    let foodRecords = records.filter(\.isNotMedicinalFood)
    let count = foodRecords.count

    guard count > 0 else { return }

    let configs: [([MealType], Bool)] = [
      ([.breakfast, .lunch, .dinner], true),
      ([.breakfast, .lunch, .dinner, .lateMeal], true),
      ([.breakfast, .lunch, .dinner], false),
      ([.breakfast, .lunch, .dinner, .lateMeal], false),
    ]

    var fittedRecords: [IBSRecord] = []
    var lowest: Double = .infinity
    for config in configs {
      let (labels, stretchTime) = config
      let scaledLabels = calcMealScales(for: records, fittedTo: labels, stretchTime: stretchTime)

      let mealRecords = scaledLabels.filter({ $0.mealType != nil })
      let fittedLabelsCount = Dictionary(grouping: mealRecords, by: \.mealType).count

      if labels.count > 3 {
        if fittedLabelsCount != labels.count { continue }
      }

      let adjustedment = Double(fittedLabelsCount)

      let score = score(for: scaledLabels) / adjustedment
      if score < lowest {
        lowest = score
        fittedRecords = scaledLabels
      }
    }

    for (i, record) in fittedRecords.enumerated() {
      records[i] = record
    }
  }

  func calcMealScales(for records: [IBSRecord], fittedTo labels: [MealType], stretchTime: Bool = false) -> [IBSRecord] {
    var records = records

    let recordTags = fitTags(labels: labels, records: records, taggable: \.isNotMedicinalFood, stretchTime: stretchTime)
    var lastTimestamp = date
    var currentTimestamp = date
    var currentMealType: MealType? = nil
    var currentIndex: Int? = nil
    for (i, mealType) in recordTags.enumerated() {
      records[i].mealType = mealType

      guard mealType != nil else { continue }

      let record = records[i]

      records[i].mealTooLate = DayRecordScales.calcMealTooLate(from: record.timestamp)

      if let currentMealType = currentMealType {
        if mealType != currentMealType {
          let cleansingDuration = record.timestamp.timeIntervalSince(lastTimestamp)
          records[i].mealTooSoon = DayRecordScales.calcMealTooSoon(from: cleansingDuration)
        } else {
          let mealDuration = record.timestamp.timeIntervalSince(currentTimestamp)
          records[i].mealTooLong = DayRecordScales.calcMealTooLong(from: mealDuration)
        }
      }

      if mealType != currentMealType {
        records[i].mealStart = true
        records[i].mealEnd = true
        currentTimestamp = record.timestamp
        currentIndex = i
      } else {
        records[i].mealEnd = true
        if let currentIndex = currentIndex {
          records[currentIndex].mealEnd = nil
        }
        currentIndex = i
      }
      lastTimestamp = record.timestamp
      currentMealType = mealType
    }

    return records
  }

  func score(for records: [IBSRecord]) -> Double {
    return records.reduce(0.0, { (sum, record) in sum + mealScore(for: record) })
  }

  func mealScore(for record: IBSRecord) -> Double {
    let mealScales: [Scales] = [record.mealTooLong ?? Scales.none, record.mealTooSoon ?? Scales.none]
    return mealScales.reduce(0.0, { (sum, scale) in
      let score = scale.rawValue < 0 ? 0 : scale.rawValue
      return sum + Double(score)
    })
  }

  func calcMetaTags(records: inout [IBSRecord]) {
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

  func fitTags(labels: [MealType], records: [IBSRecord], taggable: (IBSRecord) -> Bool, stretchTime: Bool = false) -> [MealType?] {
    let timestamps = records.filter(taggable).map(\.timestamp)
    guard timestamps.isNotEmpty else { return [] }

    let points: [Vector?] = records.map { record in
      guard taggable(record) else { return nil }
      let interval = record.timestamp.timeIntervalSince(date)
      return Vector([Double(interval)])
    }

    let convergeDistance: Double = 300 // 5 minutes (distance is measured in seconds)
    let kmm = KMeans<MealType>(labels: labels)
    let centers = kmm.calcCenters(on: date, for: timestamps, labels: labels, stretchTime: stretchTime)
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
