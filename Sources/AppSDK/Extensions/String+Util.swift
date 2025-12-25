//
//  String+Util.swift
//  AppSDK
//
//  Created by Joe Manto on 5/25/25.
//

public extension String {
    var noPadding: String {
        let start = self.firstIndex(where: { $0 != " " })
        let end = self.lastIndex(where: { $0 != " " })

        if let start, let end {
            return String(self[start...end])
        }

        if let start {
            return String(self[start...])
        } else if let end {
            return String(self[..<end])
        } else {
            return self
        }
    }

    func truncateString(limit: Int = 30) -> String {
        if self.count > limit {
            return String(self.prefix(limit + 1)) + "…"
        } else {
            return self
        }
    }
}
