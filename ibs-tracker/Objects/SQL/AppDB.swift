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
  static let current: AppDB = ibs_trackerApp.isTestRunning() ? test : app
  static let test = makeShared(.test)

  private let environment: Environment
  private static let app = makeShared(.app)

  enum Environment {
    case test
    case app
  }

  init(_ dbWriter: DatabaseWriter, environment: Environment = .test) throws {
    self.dbWriter = dbWriter
    self.environment = environment
    try migrator.migrate(dbWriter)
    try loadTags(.food)
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

  func loadTags(_ type: ItemType) throws {
    guard environment != .test else { return }
    guard try countRecords(in: SQLTagRecord.self) == 0 else { return }

    let type = type.rawValue
    guard let foodTagsURL = Bundle.main.url(forResource: "\(type)-tags", withExtension: "txt") else { return }
    guard let foodTagsString = try? String(contentsOf: foodTagsURL) else { return }
    let foodTags = foodTagsString.components(separatedBy: .newlines).filter { $0.isNotEmpty }
    for foodTag in foodTags {
      var tagRecord = SQLTagRecord(type: type, name: foodTag)
      _ = try insertRecord(&tagRecord)
    }

    try dbWriter.read { db in
      let count = try SQLTagRecord.fetchCount(db)
      print("Inserted [\(count)] \(type) tags")
    }
  }
}

extension AppDB: Equatable {
  static func == (lhs: AppDB, rhs: AppDB) -> Bool {
    lhs.environment == rhs.environment
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
