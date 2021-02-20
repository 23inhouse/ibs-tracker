//
//  SQLIBSRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/2/21.
//

import Foundation
import GRDB

struct SQLIBSRecord {
  static var databaseTableName = "IBSRecords"

  var ID: Int64?

  var timestamp: Date
  var type: String

  var text: String?
  var bristolScale: Int?
  var size: Int?
  var risk: Int?
  var bloating: Int?
  var pain: Int?
  var bodyache: Int?
  var headache: Int?
  var feel: Int?
  var stress: Int?
  var medicationType: String?
  var weight: Decimal?

  var createdAt: Date? = Date()
  var updatedAt: Date? = Date()
}

extension SQLIBSRecord: Importable {
  init(from record: IBSRecord) {
    self.timestamp = record.timestamp
    self.type = record.type.rawValue

    self.text = record.text
    self.bristolScale = record.bristolScale?.rawValue
    self.size = record.size?.rawValue
    self.risk = record.risk?.rawValue
    self.bloating = record.bloating?.rawValue
    self.pain = record.pain?.rawValue
    self.bodyache = record.bodyache?.rawValue
    self.headache = record.headache?.rawValue
    self.feel = record.feel?.rawValue
    self.stress = record.stress?.rawValue
    self.medicationType = record.medicationType?.rawValue
    self.weight = record.weight
  }
}

extension SQLIBSRecord: Codable {
  fileprivate enum Columns {
    static let ID = Column(CodingKeys.ID)

    static let timestamp = Column(CodingKeys.timestamp)
    static let type = Column(CodingKeys.type)

    static let text = Column(CodingKeys.text)
    static let bristolScale = Column(CodingKeys.bristolScale)
    static let size = Column(CodingKeys.size)
    static let risk = Column(CodingKeys.risk)
    static let bloating = Column(CodingKeys.bloating)
    static let pain = Column(CodingKeys.pain)
    static let bodyache = Column(CodingKeys.bodyache)
    static let headache = Column(CodingKeys.headache)
    static let feel = Column(CodingKeys.feel)
    static let stress = Column(CodingKeys.stress)
    static let medicationType = Column(CodingKeys.medicationType)
    static let weight = Column(CodingKeys.weight)

    static let createdAt = Column(CodingKeys.createdAt)
    static let updatedAt = Column(CodingKeys.updatedAt)
  }
}

extension SQLIBSRecord: TableRecord {
  static let ibsTagRecords = hasMany(SQLIBSTagRecord.self, using: ForeignKey(["ibsID"]))
  static let tagRecords = hasMany(SQLTagRecord.self, through: ibsTagRecords, using: SQLIBSTagRecord.tagRecords)
}

extension SQLIBSRecord: FetchableRecord {}
extension SQLIBSRecord: MutablePersistableRecord {}
extension SQLIBSRecord: IDable {}

extension SQLIBSRecord: Migratable {
  static func migrate(_ db: Database) throws {
    try db.create(table: "IBSRecords") { t in
      t.autoIncrementedPrimaryKey("ID")

      t.column("timestamp", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("type", .text)

      t.column("text", .text)
      t.column("bristolScale", .integer)
      t.column("size", .integer)
      t.column("risk", .integer)
      t.column("bloating", .integer)
      t.column("pain", .integer)
      t.column("bodyache", .integer)
      t.column("headache", .integer)
      t.column("feel", .integer)
      t.column("stress", .integer)
      t.column("medicationType", .text)
      t.column("weight", .double)

      t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }
  }
}
