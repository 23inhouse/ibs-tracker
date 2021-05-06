//
//  KMeans.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/4/21.
//

import Foundation

class KMeans {
  private let labels: [MealType]
  private let maximumNumberOfCenters: Int
  private let convergeDistance: Double
  private let minimumDistance: Double
  private let maximumDistance: Double

  private(set) var centers: [Vector] = []

  init() {
    self.labels = Array(repeating: .none, count: MealType.allCases.count)
    self.maximumNumberOfCenters = labels.count

    self.convergeDistance = 300 // 5 minutes (distance is measured in seconds)
    self.minimumDistance = 7200 // 2 hours (distance is measured in seconds)
    self.maximumDistance = 7200 // 2 hours either side of center (distance is measured in seconds)
  }

  func train(points: [Vector]) -> [MealType] {
    let sortedRandomCenters = sampleReservoir(of: points)

    var counter = 0
    var labels: [MealType] = []
    let numberOfPoints = points.count
    let maximumNumberOfAttempts = numberOfPoints * 2
    while labels.count < numberOfPoints && counter < maximumNumberOfAttempts {
      let trainedCenters = train(points: points, towards: sortedRandomCenters)
      centers = trainedCenters
      labels = points.map(fit)
      counter += 1
    }
    assert(counter < maximumNumberOfAttempts, "FULLY MAXED OUT")

    return labels
  }

  func indexes(points: [Vector]) -> [Int?] {
    points
      .map({ indexOfNearestCenter(for: $0, in: centers) })
  }
}

private extension KMeans {
  func adjust(centers: inout [Vector], from classifications: [[Vector]]) -> Double {
    let oldCenters = centers
    classifications.enumerated().forEach { (i, vectors) in
      guard centers.indices.contains(i) else { return }
      let averageVector = vectors.average
      centers[i] = Vector(from: averageVector)
    }

    return distance(from: oldCenters, to: centers)
  }

  func classify(points: [Vector], into centers: [Vector]) -> [[Vector]] {
    let numberOfCenters = centers.count
    var classifications: [[Vector]] = .init(repeating: [], count: numberOfCenters)
    for point in points {
      if let index = indexOfNearestCenter(for: point, in: centers) {
        classifications[index].append(point)
      }
    }
    return classifications
  }

  func distance(from vectors: [Vector], to others: [Vector]) -> Double {
    var distances = 0.0
    for i in 0 ..< vectors.count {
      let distance = vectors[i].distance(to: others[i])
      distances += distance
    }
    return distances
  }

  func fit(_ point: Vector) -> MealType {
    assert(!centers.isEmpty, "Exception: KMeans tried to fit on a non trained model.")

    if let centerIndex = indexOfNearestCenter(for: point, in: centers) {
      return labels[centerIndex]
    }

    return .none
  }

  func indexOfNearestCenter(for vector: Vector, in centers: [Vector]) -> Int? {
    var closestDistance = Double.greatestFiniteMagnitude
    var closestIndex: Int? = nil

    for (index, center) in centers.enumerated() {
      let distance = vector.distance(to: center)

      if distance < closestDistance && distance <= maximumDistance {
        closestIndex = index
        closestDistance = distance
      }
    }
    return closestIndex
  }

  func isUniqueCenter(randomIndex: Int, indexes: Set<Int>, points: [Vector]) -> Bool {
    guard indexes.isNotEmpty else { return true }

    for index in indexes {
      let distanceToCenter = abs(points[index].dimension(0) - points[randomIndex].dimension(0))
      if distanceToCenter <= minimumDistance {
        return false
      }
    }
    return true
  }

  func sampleIndex(indexes: Set<Int>, points: [Vector]) -> Int? {
    var samplePoints = points
    for index in indexes.sorted(by: { $0 > $1 }) {
      samplePoints.remove(at: index)
    }

    while samplePoints.isNotEmpty {
      let samplePoint = indexes.count % 2 == 0 ? samplePoints.last! : samplePoints.first!
      let randomIndex = points.firstIndex(of: samplePoint)!
      let sampleIndex = samplePoints.firstIndex(of: samplePoint)!

      if isUniqueCenter(randomIndex: randomIndex, indexes: indexes, points: points) {
        return randomIndex
      }
      samplePoints.remove(at: sampleIndex)
    }

    return nil
  }

  func sampleReservoir(of points: [Vector]) -> [Vector] {
    let count = points.count
    let sampleSize = [count, maximumNumberOfCenters].min()!

    let first = points.first!
    let last = points.last!
    let isMoreThanOne = (last.dimension(0) - first.dimension(0)) > maximumDistance
    var indexes: Set<Int> = isMoreThanOne ? [0, count - 1] : [0] // add first and last cluster

    while indexes.count < sampleSize {
      if let randomIndex = sampleIndex(indexes: indexes, points: points) {
        indexes.insert(randomIndex)
      } else {
        break
      }
    }

    return indexes.sorted().map { points[$0] }
  }

  func train(points: [Vector], towards centers: [Vector]) -> [Vector] {
    var centers = centers
    var adjustmentDistance = 0.0
    repeat {
      let classifications = classify(points: points, into: centers)
      adjustmentDistance = adjust(centers: &centers, from: classifications)
    } while adjustmentDistance > convergeDistance

    return centers
  }
}
