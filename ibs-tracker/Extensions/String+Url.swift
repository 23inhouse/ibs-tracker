//
//  String+Url.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import Foundation

extension String {
  func url(path filename: String, encoding: Encoding = .utf8) -> URL? {
    guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let fileURL = dir.appendingPathComponent(filename)

    do {
      try write(to: fileURL, atomically: false, encoding: encoding)
      return fileURL
    }
    catch {
      print("Error: \(error)")
    }
    return nil
  }

  func dataAtPath() -> Data? {
    guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let fileURL = dir.appendingPathComponent(self)

    do {
      return try Data(contentsOf: fileURL)
    } catch {
      print("Error: \(error)")
    }
    return nil
  }
}
