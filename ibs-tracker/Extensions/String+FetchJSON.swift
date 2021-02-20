//
//  String+FetchJSON.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/2/21.
//

import Foundation

extension String {
  func fetchJSON(_ parser: @escaping (Data) -> Void) {
    guard let url = URL(string: self) else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data else { return }

      parser(data)
    }.resume()
  }
}

