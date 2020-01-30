//
//  Stock.swift
//  Stock
//
//  Created by Andy Fang on 12/31/19.
//  Copyright © 2019 Andy Fang. service rights reserved.
//
import Foundation

struct Stock: Decodable {
  let name: String
  let category: Category
  let symbol: String
  
  
  enum Category: Decodable {
    case all
    case transportation
    case mining
    case foodservice
    case utilities
  }
}


extension Stock.Category: CaseIterable { }

extension Stock.Category: RawRepresentable {
  typealias RawValue = String
  
  init?(rawValue: RawValue) {
    switch rawValue {
    case "All": self = .all
    case "Transportation": self = .transportation
    case "Mining": self = .mining
    case "Food Service": self = .foodservice
    case "Utilities": self = .utilities
    default: return nil
    }
  }
  
  var rawValue: RawValue {
    switch self {
    case .all: return "All"
    case .transportation: return "Transportation"
    case .mining: return "Mining"
    case .foodservice: return "Food Service"
    case .utilities: return "Utilities"
    }
  }
}

extension Stock {
  static func stocks() -> [Stock] {
    guard
      let url = Bundle.main.url(forResource: "stocks", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([Stock].self, from: data)
    } catch {
      return []
    }
  }
}

