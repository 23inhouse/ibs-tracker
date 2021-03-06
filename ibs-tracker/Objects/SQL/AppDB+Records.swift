//
//  AppDB+Records.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/2/21.
//

import Foundation
import GRDB

extension AppDB {
  func exportRecords() throws -> [IBSRecord] {
    return try ibsRecordsWithTags()
  }

  func resetRecords() {
    do {
      try truncateRecords()
      try loadAllTags()
    } catch {
      print("Error - Can't Reset: \(error)")
    }
  }

  func importJSON(_ data: Data, truncate: Bool = false) {
    let jsonDecoder = JSONDecoder()
    do {
      let dataSet = try jsonDecoder.decode(DataSet.self, from: data)
      if truncate {
        try truncateRecords()
      }
      try loadAllTags()
      try importRecords(dataSet.ibsRecords)
    } catch {
      print("Error - Can't Import: \(error)")
    }
  }

  func importRecords(_ allRecords: [IBSRecord]) throws {
    let sortedRecords = allRecords.sorted { $0.timestamp < $1.timestamp }

    for record in sortedRecords {
      try record.insertSQL(into: self)
    }
  }

  func truncateRecords() throws {
    try deleteAllRecords(in: SQLIBSTagRecord.self)
    try deleteAllRecords(in: SQLIBSRecord.self)
    try deleteAllRecords(in: SQLTagRecord.self)
  }

  func ibsTagIDs(ibsID: Int64) throws -> [Int64?] {
    return try dbWriter.read { db in
      let request = SQLIBSTagRecord
        .select([Column("ID"), Column("ibsID"), Column("tagID")])
        .filter(Column("ibsID") == ibsID)

      return try request.fetchAll(db).map { $0.ID }
    }
  }

  func tags(of type: ItemType) throws -> [QueryInterfaceRequest<SQLTagRecord>.RowDecoder?] {
    try dbWriter.read { db in
      let recordAlias = TableAlias(name: "IBSRecords")
      let mostRecent = max(recordAlias[Column("timestamp")]).forKey("mostRecent")
      let request = SQLTagRecord
        .select(Column("type"), Column("name"), mostRecent)
        .joining(optional: SQLTagRecord.ibsRecords.aliased(recordAlias))
        .filter(Column("type") == type.rawValue)
        .order(sql: "mostRecent DESC")
        .group(Column("name"))

      return try request.fetchAll(db)
    }
  }
}

private extension AppDB {
  func ibsRecordsWithTags() throws -> [IBSRecord] {
    let sql = """
      SELECT IBSRecords.*, (
          SELECT GROUP_CONCAT(IBSTags.name, '|') AS tags
          FROM IBSTagRecords
          JOIN IBSTags
          ON IBSTags.ID = IBSTagRecords.tagID
          WHERE IBSTagRecords.ibsID = IBSRecords.ID
          ORDER BY IBSTagRecords.updatedAt ASC
        ) as tags
      FROM IBSRecords
      ORDER BY timestamp DESC
    """
    return try dbWriter.read { db in
      let rows = try Row.fetchAll(db, sql: sql)
      var calender = Calendar.current
      calender.timeZone = TimeZone(abbreviation: "UTC")!
      return try rows.map { row in
        let timestamp = String(row["timestamp"])
        let components = timestamp.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let year = Int(components[0])
        let month = Int(components[1])
        let day = Int(components[2])
        let hour = Int(components[3])
        let minute = Int(components[4])
        guard let date = calender.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) else {
          throw "Couldn't create the date"
        }

        let medicationTypes = String(row["medicationType"] ?? "").split(separator: "|").filter { $0 != "" }
        let ibsRecord = IBSRecord(
          type: ItemType(rawValue: row["type"]) ?? .none,
          timestamp: date,
          bristolScale: BristolType(optionalValue: row["bristolScale"]),
          color: BMColor(optionalValue: row["color"]),
          pressure: Scales(optionalValue: row["pressure"]),
          smell: BMSmell(optionalValue: row["smell"]),
          evacuation: BMEvacuation(optionalValue: row["evacuation"]),
          dryness: Scales(optionalValue: row["dryness"]),
          wetness: Scales(optionalValue: row["wetness"]),
          text: row["text"],
          size: FoodSizes(optionalValue: row["size"]),
          risk: Scales(optionalValue: row["risk"]),
          speed: Scales(optionalValue: row["speed"]),
          pain: Scales(optionalValue: row["pain"]),
          bloating: Scales(optionalValue: row["bloating"]),
          bodyache: Scales(optionalValue: row["bodyache"]),
          headache: Scales(optionalValue: row["headache"]),
          feel: MoodType(optionalValue: row["feel"]),
          stress: Scales(optionalValue: row["stress"]),
          medicationType: row["medicationType"] != nil ? medicationTypes.map { MedicationType(optionalValue: String($0))! } : nil,
          weight: row["weight"] != nil ? Decimal(floatLiteral: row["weight"]) : nil,
          condition: Scales(optionalValue: row["condition"]),
          medicinal: row["medicinal"],
          tags: String(row["tags"] ?? "").components(separatedBy: "|").filter { $0 != ""}
        )
        return ibsRecord
      }
    }
  }
}
