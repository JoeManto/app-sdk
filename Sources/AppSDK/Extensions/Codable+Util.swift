//
//  Codable+Util.swift
//  AppSDK
//
//  Created by Joe Manto on 5/25/25.
//

import Foundation

public extension Encodable {
    var asDictionary: [String: Any] {
        get throws {
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            return dictionary
        }
    }
}

public extension Decodable {
    init(from dictionary: [AnyHashable: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
