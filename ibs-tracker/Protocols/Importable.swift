//
//  Importable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 8/2/21.
//

import Foundation

protocol Importable {
  init(from record: IBSRecord)
}
