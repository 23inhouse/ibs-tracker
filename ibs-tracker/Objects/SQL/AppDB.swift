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
    try loadAllTags()
  }

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    if environment == .test {
      migrator.eraseDatabaseOnSchemaChange = true
    }

    migrator.registerMigration("v1") { db in
      try SQLIBSRecord.initialize(db)
      try SQLTagRecord.initialize(db)
      try SQLIBSTagRecord.initialize(db)
    }

    migrator.registerMigration("v2") { db in
      try SQLIBSRecord.addMedicinalColumn(db)
    }

    migrator.registerMigration("v3") { db in
      try SQLIBSRecord.addSpeedColumn(db)
    }

    return migrator
  }

  func loadAllTags() throws {
    do {
      for type in ItemType.allCases {
        guard type != .none else { continue }
        try loadTags(type)
      }
    } catch {
      print(error)
      throw error
    }
  }
}

extension AppDB: Equatable {
  static func == (lhs: AppDB, rhs: AppDB) -> Bool {
    lhs.environment == rhs.environment
  }
}

private extension AppDB {
  static func makeShared(_ environment: Environment) -> AppDB {
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

private extension AppDB {
  func loadTags(_ type: ItemType) throws {
    guard environment != .test else { return }

    let type = type.rawValue

    guard try countRecords(in: SQLTagRecord.self, of: type) == 0 else { return }
    guard let tagsURL = Bundle.main.url(forResource: "\(type)-tags", withExtension: "txt") else {
      throw "Can't find the file URL named: [\(type)-tags.txt]"
    }
    guard let tagsString = try? String(contentsOf: tagsURL) else {
      throw "Can't read the contents of [\(type)-tags.txt]"
    }

    let tags = tagsString.components(separatedBy: .newlines).filter { $0.isNotEmpty }
    for tag in tags {
      var tagRecord = SQLTagRecord(type: type, name: tag)
      _ = try insertRecord(&tagRecord)
    }


    let count = try countRecords(in: SQLTagRecord.self, of: type)
    print("Inserted [\(count)] \(type) tags")
  }
}
