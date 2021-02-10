//
//  AppDB+MutablePersistableRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 10/2/21.
//

import GRDB

extension AppDB {
  func countRecords<T>(in _: T.Type) throws -> Int where T: MutablePersistableRecord {
    try dbWriter.write { db in
      return try T.fetchCount(db)
    }
  }

  func deleteRecords<T>(in table: T.Type, ids: [Int64]) throws where T: MutablePersistableRecord {
    try dbWriter.write { db in
      _ = try table.deleteAll(db, keys: ids)
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

  func selectRecord<T>(in _: T.Type, named name: String) throws -> QueryInterfaceRequest<T>.RowDecoder? where T: FetchableRecord & TableRecord {
    try dbWriter.read { db in
      let request = T
        .select([Column("ID"), Column("name")])
        .filter(key: ["name": name])
        .limit(1)

      return try request.fetchOne(db)
    }
  }
}
