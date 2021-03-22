//
//  Array+Chunked.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/3/21.
//

import Foundation

extension Array {
  func chunked(into chunks: Int) -> [[Element]] {
    let size = Int(ceil(Double(count) / Double(chunks)))
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
