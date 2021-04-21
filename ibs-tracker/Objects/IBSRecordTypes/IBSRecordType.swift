//
//  IBSRecordType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol IBSRecordType {
  var timestamp: Date { get }
  var tags: [String] { get }
  func deleteSQL(into appDB: AppDB) throws
}
