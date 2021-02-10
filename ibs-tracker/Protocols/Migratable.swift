//
//  Migratable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/2/21.
//

import GRDB

protocol Migratable: MutablePersistableRecord {
  static func migrate(_ db: Database) throws
}
