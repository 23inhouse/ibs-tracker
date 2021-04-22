//
//  Vector.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/4/21.
//

import Foundation

struct Vector {
  static let maximumNumberOfDimensions = 1

  private let data: [Double]
  let numberOfDimensions: Int
  let weighting: Double

  init(_ data: [Double], weighting: Double = 1) {
    assert(data.count <= Vector.maximumNumberOfDimensions, "Data exceeds maximum number of dimensions")
    self.data = data
    self.numberOfDimensions = data.count
    self.weighting = weighting
  }

  init(from other: Vector, weighting: Double = 1) {
    let numberOfDimensions = other.numberOfDimensions
    self.data = other.data
    self.numberOfDimensions = numberOfDimensions
    self.weighting = weighting
  }

  func dimension(_ index: Int) -> Double {
    assert(index <= numberOfDimensions, "Dimension [\(index)] is out of range. Must be less than or equal to [\(numberOfDimensions)]")
    return data[index]
  }

  func distance(to other: Vector) -> Double {
    let result: Double = data.enumerated().reduce(0.0) { sum, data in
      let distance = pow(data.element - other.data[data.offset], 2)
      let weighting = pow(other.weighting, 2)
      return sum + distance / weighting
    }

    return sqrt(result)
  }
}

extension Vector: CustomStringConvertible {
  var description: String {
    return "Vector [\(data)] weighting: \(weighting)"
  }
}

extension Vector: AdditiveArithmetic {
  static var zero: Vector {
    Vector([Double](repeating: 0, count: maximumNumberOfDimensions))
  }

  static func + (lhs: Vector, rhs: Vector) -> Vector {
    var data = [Double]()
    for i in 0 ..< min(lhs.numberOfDimensions, rhs.numberOfDimensions) {
      data.append(lhs.dimension(i) + rhs.dimension(i))
    }
    return Vector(data)
  }

  static func - (lhs: Vector, rhs: Vector) -> Vector {
    var data = [Double]()
    for i in 0 ..< min(lhs.numberOfDimensions, rhs.numberOfDimensions) {
      data.append(lhs.dimension(i) - rhs.dimension(i))
    }
    return Vector(data)
  }
}

extension Array where Element == Vector {
  var average: Element {
    let sum = reduce(Vector.zero, +)
    var data = [Double](repeating: 0, count: Vector.maximumNumberOfDimensions)
    for i in 0 ..< Vector.maximumNumberOfDimensions {
      data[i] = sum.dimension(i) / Double(count)
    }
    return Vector(data)
  }
}
