//
//  AppDB+Idable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 10/2/21.
//

import GRDB

extension AppDB {
  func insertRecord<T>(_ record: inout T) throws -> Int64 where T: IDable {
    try dbWriter.write { db in
      try record.insert(db)
      guard let id = record.ID else {
        throw "No id created for [\(record)]"
      }
      return id
    }
  }
}
