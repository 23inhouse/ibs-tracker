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

extension DataSet: Decodable {
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    ibsRecords = try values.decodeIfPresent([IBSRecord].self, forKey: .ibsRecords) ?? []
  }
}
