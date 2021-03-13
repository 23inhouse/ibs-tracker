//
//  Data+Url.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/3/21.
//

import Foundation

extension Data {
  func url(path filename: String) -> URL? {
    guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let fileURL = dir.appendingPathComponent(filename)

    do {
      try write(to: fileURL, options: .atomic)
      return fileURL
    } catch {
      print("Error: \(error)")
    }
    return nil
  }
}
