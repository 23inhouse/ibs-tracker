//
//  AppDB.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/2/21.
//

import Foundation
import GRDB

struct AppDB {
  let dbWriter: DatabaseWriter
  private let environment: Environment

  static let app = makeShared(.app)
  static let test = makeShared(.test)

  enum Environment {
    case test
    case app
  }

  init(_ dbWriter: DatabaseWriter, environment: Environment = .test) throws {
    self.dbWriter = dbWriter
    self.environment = environment
    try migrator.migrate(dbWriter)
  }

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    if environment == .test {
      migrator.eraseDatabaseOnSchemaChange = true
    }

    migrator.registerMigration("v1") { db in
      try SQLIBSRecord.migrate(db)
      try SQLTagRecord.migrate(db)
      try SQLIBSTagRecord.migrate(db)
    }

    return migrator
  }
}

extension AppDB {
  private static func makeShared(_ environment: Environment) -> AppDB {
    do {
      let url: URL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("\(environment)-db.sqlite")
      print("AppDB: Opening \(environment)-db.sqlite")
      let dbPool = try DatabasePool(path: url.path)
      let appDB = try AppDB(dbPool, environment: environment)

      return appDB
    } catch {
      fatalError("Unresolved error \(error)")
    }
  }
}
