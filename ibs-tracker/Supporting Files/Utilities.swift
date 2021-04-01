//
//  Utilities.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import Foundation
import GRDB

struct Utilities {
  static func measure(_ block: () -> Void) {
    let start = DispatchTime.now()
    block()
    let end = DispatchTime.now()

    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = round(Double(nanoTime) / 1_000_000) / 1_000
    print("Executed in: \(timeInterval) seconds")
  }

  static func debugSQL<T>(request: QueryInterfaceRequest<T>, db: Database) where T: FetchableRecord & TableRecord & MutablePersistableRecord {
    do {
      let statement = try request.makePreparedRequest(db).statement
      print(statement.sql)
    } catch {
      print("Error can't prepare request: \(error)")
    }
  }
}
