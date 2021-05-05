//
//  KMeans.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/4/21.
//

import Foundation

class KMeans<Label: Hashable> {
  let labels: [Label]

  private(set) var centroids = [Vector]()
  private let numberOfCenters: Int

  init(labels: [Label]) {
    self.labels = labels
    self.numberOfCenters = labels.count
  }

  func fit(_ points: [Vector?]) -> [Label?] {
    assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")

    return points.map(fit)
  }

  func calcCenters(on date: Date, for timestamps: [Date], labels: [MealType], stretchTime: Bool = false) -> [Vector] {
    guard timestamps.isNotEmpty else { return [] }
    let hour: Double = 60 * 60

    let firstMealTime = timestamps.first!.timeIntervalSince(date)

    let mealInterval = timestamps.last!.timeIntervalSince(timestamps.first!)
    let gapModifier: Double

    if stretchTime == false || mealInterval < (6 * hour) {
      gapModifier = 1.0
    } else {
      let totalHours = labels.count == 3 ? 8.0 : 10.5
      gapModifier = mealInterval / (totalHours * hour)
    }

    let breakfastTime = firstMealTime
    let lunchTime     = firstMealTime + (4 * hour * gapModifier)
    let dinnerTime    = firstMealTime + (8 * hour * gapModifier)
    let snackTime     = firstMealTime + (10.5 * hour * gapModifier)

    let breakfast = Vector([breakfastTime], weighting: 1.1)
    let lunch     = Vector([lunchTime], weighting: 1.0)
    let dinner    = Vector([dinnerTime], weighting: 1.1)
    let snack     = Vector([snackTime], weighting: 0.9)

    let moreThanThree = labels.count > 3 && timestamps.count > 3 && mealInterval > (11 * hour)
    let centers = moreThanThree ? [breakfast, lunch, dinner, snack] : [breakfast, lunch, dinner]

    return centers
  }

  func sortCenters() {
    centroids = centroids.sorted(by: { $0.dimension(0) < $1.dimension(0) })
  }

  func train(points: [Vector], convergeDistance: Double, towards centers: [Vector]? = nil) {
    var centers = centers ?? sampleReservoir(points, numberOfCenters)

    var adjustmentDistance = 0.0
    repeat {
      let classifications = classify(points: points, into: centers)
      adjustmentDistance = adjust(centers: &centers, from: classifications)
    } while adjustmentDistance > convergeDistance

    centroids = centers
  }
}

private extension KMeans {
  func adjust(centers: inout [Vector], from classifications: [[Vector]]) -> Double {
    let oldCenters = centers
    classifications.enumerated().forEach { (i, vectors) in
      guard centers.indices.contains(i) else { return }
      let averageVector = vectors.average
      let weighting = centers[i].weighting
      centers[i] = Vector(from: averageVector, weighting: weighting)
    }

    return distance(from: oldCenters, to: centers)
  }

  func classify(points: [Vector], into centers: [Vector]) -> [[Vector]] {
    var classifications: [[Vector]] = .init(repeating: [], count: numberOfCenters)
    for point in points {
      let index = indexOfNearestCenter(point, centers: centers)
      classifications[index].append(point)
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

  func fit(_ point: Vector?) -> Label? {
    assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")
    guard let point = point else { return nil }

    let centroidIndex = indexOfNearestCenter(point, centers: centroids)
    return labels[centroidIndex]
  }

  func indexOfNearestCenter(_ vector: Vector, centers: [Vector]) -> Int {
    var nearestDistance = Double.greatestFiniteMagnitude
    var minimumIndex = 0

    for (index, center) in centers.enumerated() {
      let distance = vector.distance(to: center)

      if distance < nearestDistance {
        minimumIndex = index
        nearestDistance = distance
      }
    }
    return minimumIndex
  }

  // Pick k random elements from samples
  func sampleReservoir<T>(_ samples: [T], _ numberOfCenters: Int) -> [T] {
    var result = [T]()

    // Fill the result array with first k elements
    for i in 0 ..< numberOfCenters {
      result.append(samples[i])
    }

    // Randomly replace elements from remaining pool
    for i in numberOfCenters ..< samples.count {
      let j = Int.random(in: 0 ... i)
      if j < numberOfCenters {
        result[j] = samples[i]
      }
    }
    return result
  }
}
