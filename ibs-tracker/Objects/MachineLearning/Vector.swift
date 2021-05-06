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

  init(_ data: [Double]) {
    assert(data.count <= Vector.maximumNumberOfDimensions, "Data exceeds maximum number of dimensions")
    self.data = data
    self.numberOfDimensions = data.count
  }

  init(from other: Vector) {
    let numberOfDimensions = other.numberOfDimensions
    self.data = other.data
    self.numberOfDimensions = numberOfDimensions
  }

  func dimension(_ index: Int) -> Double {
    assert(index <= numberOfDimensions, "Dimension [\(index)] is out of range. Must be less than or equal to [\(numberOfDimensions)]")
    return data[index]
  }

  func distance(to other: Vector) -> Double {
    let result: Double = data.enumerated().reduce(0.0) { sum, data in
      let distance = abs(data.element - other.data[data.offset])
      return sum + distance
    }

    return result / Double(numberOfDimensions)
  }
}

extension Vector: CustomStringConvertible {
  var description: String {
    return "Vector [\(data.map { "\(floor($0 / 60 / 60 * 1000) / 1000)" })]"
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
