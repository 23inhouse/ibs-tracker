//
//  DataSet.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import Foundation

struct DataSet {
  var ibsRecords: [IBSRecord]

  enum CodingKeys: String, CodingKey {
    case ibsRecords = "ibs-records"
  }
}

extension DataSet: Codable {
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    ibsRecords = try values.decodeIfPresent([IBSRecord].self, forKey: .ibsRecords) ?? []
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(ibsRecords, forKey: .ibsRecords)
  }
}

extension DataSet {
  static func encode(_ dataSet: DataSet) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
      let data = try encoder.encode(dataSet)
      return String(data: data, encoding: .utf8)
    } catch {
      print("Error: \(error)")
    }

    return nil
  }

  static func jsonFileUrl() -> URL? {
    do {
      let records: [IBSRecord] = try AppDB.current.exportRecords()
      let dataSet = DataSet(ibsRecords: records)
      return DataSet.encode(dataSet)?.url(path: "export.json")
    } catch {
      print("Error: \(error)")
    }
    return nil
  }
}
