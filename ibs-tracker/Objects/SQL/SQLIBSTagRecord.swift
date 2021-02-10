//
//  SQLIBSTagRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 8/2/21.
//

import Foundation
import GRDB

struct SQLIBSTagRecord {
  static var databaseTableName = "IBSTagRecords"

  var ID: Int64?

  var ibsID: Int64
  var tagID: Int64

  var createdAt: Date? = Date()
  var updatedAt: Date? = Date()
}

extension SQLIBSTagRecord: Codable {
  fileprivate enum Columns {
    static let ID = Column(CodingKeys.ID)

    static let ibsID = Column(CodingKeys.ibsID)
    static let tagID = Column(CodingKeys.tagID)

    static let createdAt = Column(CodingKeys.createdAt)
    static let updatedAt = Column(CodingKeys.updatedAt)
  }
}

extension SQLIBSTagRecord: TableRecord {
  static let ibsRecords = belongsTo(SQLIBSRecord.self)
  static let tagRecords = belongsTo(SQLTagRecord.self)
}

extension SQLIBSTagRecord: FetchableRecord {}
extension SQLIBSTagRecord: MutablePersistableRecord {}
extension SQLIBSTagRecord: IDable {}

extension SQLIBSTagRecord: Migratable {
  static func migrate(_ db: Database) throws {
    try db.create(table: "IBSTagRecords") { t in
      t.autoIncrementedPrimaryKey("ID")

      t.column("ibsID", .integer).notNull().indexed()
        .references("IBSRecords")
      t.column("tagID", .integer).notNull().indexed()
        .references("IBSTags")

      t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }
  }
}
