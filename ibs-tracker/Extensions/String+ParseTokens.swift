//
//  String+ParseTokens.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 3/5/21.
//

import Foundation

extension String {
  func parseTokens() -> [String] {
    let delimiter = Character(" ")
    let startQuote = Character("“")
    let endQuote = Character("”")

    var tokens = [String]()
    var pending = ""
    var isQuoted = false

    for character in self {
      if character == startQuote || character == endQuote {
        isQuoted = !isQuoted
      } else if character == delimiter && !isQuoted {
        tokens.append(pending)
        pending = ""
      } else {
        pending.append(character)
      }
    }

    if pending.isNotEmpty {
      tokens.append(pending)
    }

    return tokens
  }
}
