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
  var color: String?
  var pressure: Int?
  var smell: String?
  var evacuation: String?
  var dryness: Int?
  var wetness: Int?
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

    set(from: record)
  }
}

extension SQLIBSRecord: Codable {
  fileprivate enum Columns {
    static let ID = Column(CodingKeys.ID)

    static let timestamp = Column(CodingKeys.timestamp)
    static let type = Column(CodingKeys.type)

    static let text = Column(CodingKeys.text)
    static let bristolScale = Column(CodingKeys.bristolScale)
    static let color = Column(CodingKeys.color)
    static let pressure = Column(CodingKeys.pressure)
    static let smell = Column(CodingKeys.smell)
    static let evacuation = Column(CodingKeys.evacuation)
    static let dryness = Column(CodingKeys.dryness)
    static let wetness = Column(CodingKeys.wetness)
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
      t.column("color", .text)
      t.column("pressure", .integer)
      t.column("smell", .text)
      t.column("evacuation", .text)
      t.column("dryness", .integer)
      t.column("wetness", .integer)
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

      t.uniqueKey(["timestamp", "type"])
    }

    try db.create(index: "timestamp", on: "IBSRecords", columns: ["timestamp"], unique: false)
    try db.create(index: "timestamp-type", on: "IBSRecords", columns: ["timestamp", "type"])
  }
}

extension SQLIBSRecord {
  mutating func update(from record: IBSRecord) {
    set(from: record)
    updatedAt = Date()
  }
}

private extension SQLIBSRecord {
  mutating func set(from record: IBSRecord) {
    timestamp = record.timestamp
    type = record.type.rawValue

    text = record.text
    bristolScale = record.bristolScale?.rawValue
    color = record.color?.rawValue
    pressure = nonNegativeOrNil(record.pressure?.rawValue)
    smell = record.smell?.rawValue
    evacuation = record.evacuation?.rawValue
    dryness = nonNegativeOrNil(record.dryness?.rawValue)
    wetness = nonNegativeOrNil(record.wetness?.rawValue)
    size = nonNegativeOrNil(record.size?.rawValue)
    risk = nonNegativeOrNil(record.risk?.rawValue)
    bloating = nonNegativeOrNil(record.bloating?.rawValue)
    pain = nonNegativeOrNil(record.pain?.rawValue)
    bodyache = nonNegativeOrNil(record.bodyache?.rawValue)
    headache = nonNegativeOrNil(record.headache?.rawValue)
    feel = nonNegativeOrNil(record.feel?.rawValue)
    stress = nonNegativeOrNil(record.stress?.rawValue)
    medicationType = record.medicationType?.map { $0.rawValue }.joined(separator: "|")
    weight = record.weight
  }

  func nonNegativeOrNil(_ value: Int?) -> Int? {
    guard let value = value else { return nil }
    guard value >= 0 else { return nil }
    return value
  }
}
