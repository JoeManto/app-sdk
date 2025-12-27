//
//  CLIDataFilterOption.swift
//  AppSDK
//
//  Created by Joe Manto on 12/26/25.
//

import Foundation

@available(macOS 13.0, *)
public struct CLIDataFilterOption {
    public enum ComparisonOperator: String {
        case equal = "=="
        case notEqual = "!="
        case lessThan = "<"
        case lessThanOrEquals = "<="
        case greaterThan = ">"
        case greaterThanOrEquals = ">="
    }

    public let key: String
    public let value: Float
    public let comparisonOperator: ComparisonOperator

    public init(key: String, value: Float, comparisonOperator: ComparisonOperator) {
        self.key = key
        self.value = value
        self.comparisonOperator = comparisonOperator
    }

    public init(filterString: String) throws {
        let trimmedFilterString = filterString.trimmingCharacters(in: .whitespacesAndNewlines)
        let comparisonOperator: ComparisonOperator = if trimmedFilterString.contains("==") {
            .equal
        } else if trimmedFilterString.contains("!=") {
            .notEqual
        } else if trimmedFilterString.contains(">=") {
            .greaterThanOrEquals
        } else if trimmedFilterString.contains("<=") {
                .lessThanOrEquals
        } else if trimmedFilterString.contains(">") {
            .greaterThan
        } else if trimmedFilterString.contains("<") {
            .lessThan
        } else {
            throw AppError.invalidInput("Invalid comparison operator in filter: \(trimmedFilterString)")
        }

        let components = trimmedFilterString.split(separator: comparisonOperator.rawValue)

        guard components.count == 2, let key = components.first, let value = components.last else {
            throw AppError.invalidInput("Expected two components in data filter: \(trimmedFilterString)")
        }

        guard let floatValue = Float(String(value)) else {
            throw AppError.invalidInput("Value must be a number in filter: \(trimmedFilterString)")
        }

        self.init(key: String(key), value: floatValue, comparisonOperator: comparisonOperator)
    }

    public func includes(_ value: Float) -> Bool {
        switch comparisonOperator {
        case .equal:
            return value == self.value
        case .notEqual:
            return value != self.value
        case .lessThan:
            return value < self.value
        case .lessThanOrEquals:
            return value <= self.value
        case .greaterThan:
            return value > self.value
        case .greaterThanOrEquals:
            return value >= self.value
        }
    }
}

@available(macOS 13.0, *)
public extension [CLIDataFilterOption] {
    init(filtersString: String) throws {
        let dataFilters = filtersString.split(separator: ",", omittingEmptySubsequences: true).map { String($0) }
        self = try dataFilters.map { try CLIDataFilterOption(filterString: $0)}
    }
}
