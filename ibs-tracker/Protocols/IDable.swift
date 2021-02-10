//
//  Idable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 8/2/21.
//

import GRDB

protocol IDable: MutablePersistableRecord {
  var ID: Int64? { get set }
}

extension IDable {
  mutating func didInsert(with rowID: Int64, for column: String?) {
    ID = rowID
  }
}
