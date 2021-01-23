//
//  StringProtocol+Case.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 19/1/21.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
