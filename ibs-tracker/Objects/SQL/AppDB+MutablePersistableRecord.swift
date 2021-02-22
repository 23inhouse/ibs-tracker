//
//  AppDB+MutablePersistableRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 10/2/21.
//

import Foundation
import GRDB

extension AppDB {
  func countRecords<T>(in _: T.Type) throws -> Int where T: MutablePersistableRecord {
    try dbWriter.write { db in
      return try T.fetchCount(db)
    }
  }

  func deleteRecords<T>(in _: T.Type, ids: [Int64]) throws where T: MutablePersistableRecord {
    try dbWriter.write { db in
      _ = try T.deleteAll(db, keys: ids)
    }
  }

  func deleteAllRecords<T>(in _: T.Type) throws where T: MutablePersistableRecord {
    try dbWriter.write { db in
      _ = try T.deleteAll(db)
    }
  }

  func saveRecord<T>(_ record: inout T) throws where T: MutablePersistableRecord {
    try dbWriter.write { db in
      try record.save(db)
    }
  }

  func selectRecord<T>(in _: T.Type, of type: String, named name: String) throws -> QueryInterfaceRequest<T>.RowDecoder? where T: FetchableRecord & TableRecord {
    try dbWriter.read { db in
      let request = T
        .filter(key: ["type": type, "name": name])
        .limit(1)

      return try request.fetchOne(db)
    }
  }

  func selectRecord<T>(in _: T.Type, of type: String, at timestamp: Date) throws -> QueryInterfaceRequest<T>.RowDecoder? where T: FetchableRecord & TableRecord & MutablePersistableRecord {
    try dbWriter.read { db in
      let request = T
        .filter(key: ["type": type, "timestamp": timestamp])
        .limit(1)

      return try request.fetchOne(db)
    }
  }

  func selectRecord<T>(in _: T.Type, at timestamp: Date) throws -> QueryInterfaceRequest<T>.RowDecoder? where T: FetchableRecord & TableRecord & MutablePersistableRecord {
    try dbWriter.read { db in
      let request = T
        .filter(Column("timestamp") == timestamp)
        .limit(1)

      return try request.fetchOne(db)
    }
  }
}
