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
    let metaBMRecords = calcBMMetaRecords(records: &mutatableRecords)
    calcFoodMetaRecords(records: &mutatableRecords)
    calcMetaTags(records: &mutatableRecords)

    records = (metaBMRecords + mutatableRecords)
      .sorted { $0.timestamp > $1.timestamp } // return latest first
  }

  func calcBMMetaRecords(records: inout [IBSRecord]) -> [IBSRecord] {
    guard date != IBSData.timeShiftedDate() else { return [] }

    let unfilteredRecordsBMRecords = unfilteredRecords.filter { $0.type == .bm }
    let count = unfilteredRecordsBMRecords.count

    guard count > 0 else {
      let constipationTimestamp = adjustedTimestamp(at: 1)
      return [IBSRecord(timestamp: constipationTimestamp, bristolScale: .b0)]
    }

    var numberOfBMs = 0
    for (i, record) in records.enumerated() {
      guard record.type == .bm else { continue }

      records[i].numberOfBMs = UInt(numberOfBMs)
      numberOfBMs += 1
    }

    return []
  }

  func calcFoodMetaRecords(records: inout [IBSRecord]) {
    let foodRecords = records.filter(\.isNotMedicinalFood)
    let count = foodRecords.count

    guard count > 0 else { return }

    let mealScaledRecords = calcMealScales(for: records)

    for (i, record) in mealScaledRecords.enumerated() {
      records[i] = record
    }
  }

  func calcMealScales(for records: [IBSRecord]) -> [IBSRecord] {
    var records = records

    let mealLabels = calcMeals(records: records)

    var lastTimestamp = date
    var currentTimestamp = date
    var currentMealType: MealType? = nil
    var currentIndex: Int? = nil
    for (index, mealType) in mealLabels.enumerated() {
      records[index].mealType = mealType

      guard mealType != nil else { continue }

      let record = records[index]

      records[index].mealTooLate = DayRecordScales.calcMealTooLate(from: record.timestamp)

      if let currentMealType = currentMealType {
        if mealType != currentMealType {
          let cleansingDuration = record.timestamp.timeIntervalSince(lastTimestamp)
          records[index].mealTooSoon = DayRecordScales.calcMealTooSoon(from: cleansingDuration)
        } else {
          let mealDuration = record.timestamp.timeIntervalSince(currentTimestamp)
          records[index].mealTooLong = DayRecordScales.calcMealTooLong(from: mealDuration)
        }
      }

      if mealType != currentMealType {
        records[index].mealStart = true
        records[index].mealEnd = true
        currentTimestamp = record.timestamp
        currentIndex = index
      } else {
        records[index].mealEnd = true
        if let currentIndex = currentIndex {
          records[currentIndex].mealEnd = nil
        }
        currentIndex = index
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

  func calcMeals(records: [IBSRecord]) -> [MealType?] {
    let kmm = KMeans()

    let taggableRecords = records.filter(\.isNotMedicinalFood)
    let taggablePoints: [Vector] = vectorize(records: taggableRecords)
    _ = kmm.train(points: taggablePoints)

    let points: [Vector] = vectorize(records: records)
    let indexes = kmm.indexes(points: points)

    let labels = calcLabels(centers: kmm.centers, indexes: indexes, records: records)
    return indexes.map { $0 != nil ? labels[$0!] : nil }
  }

  func calcLabels(centers: [Vector], indexes: [Int?], records: [IBSRecord]) -> [MealType] {
    let mainMeals: [MealType] = [.breakfast, .lunch, .dinner]

    let numberOfMeals = centers.count
    guard numberOfMeals != 3 else { return mainMeals }

    let timestamps = records.map { $0.timestamp }
    let groupedTimestamps = group(timestamps: timestamps, by: indexes)

    let hour: Double = 60 * 60
    let minimumMealSpacing: Double = 3 * hour
    let maximumMealSkippingLunchSpacing: Double = 7.5 * hour
    let maximumSnackDuration: Double = 4.083 * hour

    var currentMealIndex = 0
    var snacks: [MealType] = []
    var labels: [MealType] = [.breakfast]

    for (i, key) in groupedTimestamps.keys.sorted().dropFirst().enumerated() {
      if snacks.isEmpty {
        snacks = [.snack1, .snack2, .snack3, .snack4, .snack5, .snack6]
      }
      let groupedTimestamp = groupedTimestamps[key]!
      let currentMealStartTimestamp = groupedTimestamp.first!
      let currentMealEndTimestamp = groupedTimestamp.last!
      let lastMealCenterTimestamp = date.addingTimeInterval(centers[i].dimension(0))

      let mealSpacingInterval = currentMealStartTimestamp.timeIntervalSince(lastMealCenterTimestamp)
      let mealDurationInterval = currentMealEndTimestamp.timeIntervalSince(currentMealStartTimestamp)

      let isShortIntervalSinceLastMeal = mealSpacingInterval < minimumMealSpacing
      let isDinnerAssigned = labels.contains(.dinner)
      let isShortMeal = mealDurationInterval < maximumSnackDuration

      let isBreakfastCurrentMeal = currentMealIndex == 0
      let isIntervalSkippingAMeal = mealSpacingInterval > maximumMealSkippingLunchSpacing
      let isSkippingLunch = isBreakfastCurrentMeal && isIntervalSkippingAMeal
      let isLastMealASnack = !mainMeals.contains(labels.last!)

      if isShortIntervalSinceLastMeal && (isDinnerAssigned || (!isLastMealASnack && isShortMeal)) {
        labels.append(snacks.removeFirst())
      } else {
        let nextMealIndex = isSkippingLunch ? 2 : 1
        currentMealIndex += nextMealIndex
        let mealType = currentMealIndex < mainMeals.count ? mainMeals[currentMealIndex] : snacks.removeFirst()
        labels.append(mealType)
      }
    }

    return labels
  }

  func group(timestamps: [Date], by indexes: [Int?]) -> [Int: [Date]] {
    var groupedTimestamps: [Int: [Date]] = [:]
    for (index, timestamp) in timestamps.enumerated() {
      guard let key = indexes[index] else { continue }
      if groupedTimestamps[key] == nil {
        groupedTimestamps[key] = [timestamp]
      } else {
        groupedTimestamps[key]?.append(timestamp)
      }
    }

    return groupedTimestamps
  }

  func vectorize(records: [IBSRecord]) -> [Vector] {
    let timestamps = records.map(\.timestamp)
    guard timestamps.isNotEmpty else { return [] }

    return timestamps.enumerated().map { (i, timestamp) in
      guard records[i].isNotMedicinalFood else { return Vector.zero }

      let interval = timestamp.timeIntervalSince(date)
      return Vector([Double(interval)])
    }
  }

  func adjustedTimestamp(at adjustment: Int) -> Date {
    let hourOfDay = IBSData.numberOfHoursInMorningIncludedInPreviousDay + adjustment
    let interval = Double(hourOfDay * 60 * 60)
    return date.addingTimeInterval(interval)
  }
}
