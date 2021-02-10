//
//  SQLTagRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/2/21.
//

import Foundation
import GRDB

struct SQLTagRecord {
  static var databaseTableName = "IBSTags"

  var ID: Int64?

  var name: String

  var createdAt: Date? = Date()
  var updatedAt: Date? = Date()
}

extension SQLTagRecord: Codable {
  fileprivate enum Columns {
    static let ID = Column(CodingKeys.ID)

    static let name = Column(CodingKeys.name)

    static let createdAt = Column(CodingKeys.createdAt)
    static let updatedAt = Column(CodingKeys.updatedAt)
  }
}

extension SQLTagRecord: TableRecord {
  static let ibsTagRecords = hasMany(SQLIBSTagRecord.self, using: ForeignKey(["tagID"]))
  static let ibsRecords = hasMany(SQLIBSRecord.self, through: ibsTagRecords, using: SQLIBSTagRecord.ibsRecords)
}

extension SQLTagRecord: FetchableRecord {}
extension SQLTagRecord: MutablePersistableRecord {}
extension SQLTagRecord: IDable {}

extension SQLTagRecord: Migratable {
  static func migrate(_ db: Database) throws {
    try db.create(table: "IBSTags") { t in
      t.autoIncrementedPrimaryKey("ID")

      t.column("name").unique()

      t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }
  }
}
