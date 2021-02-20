//
//  Date+Nearest.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import Foundation

extension Date {
  func nearest(_ interval: Int, _ component: Calendar.Component) -> Date {
    let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
    let differentDate = Calendar.current.date(byAdding: component, value: interval, to: referenceDate)!
    let roundingFactor = differentDate.timeIntervalSinceReferenceDate

    let currentInterval = timeIntervalSinceReferenceDate
    let nearestInteraval = (currentInterval / roundingFactor).rounded(.toNearestOrAwayFromZero) * roundingFactor
    return Date(timeIntervalSinceReferenceDate: nearestInteraval)
  }
}
