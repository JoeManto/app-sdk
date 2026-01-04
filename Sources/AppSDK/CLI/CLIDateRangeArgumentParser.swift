//
//  CLIDateRangeArgumentParser.swift
//  AppSDK
//
//  Created by Joe Manto on 12/19/25.
//

import Foundation

@available(macOS 13.0, *)
public struct CLIDateRangeArgumentParser {
    enum ConvenienceDateOptions: String, CaseIterable {
        case today
        case yesterday
        case thisWeek = "this-week"
        case lastWeek = "last-week"
        case thisMonth = "this-month"
        case lastMonth = "last-month"
        case thisYear = "this-year"
        case lastYear = "last-year"
    }

    public let range: ClosedRange<Date>

    static let rangeSplitSeparator = "..."

    public init(rangeString: String) throws {
        self.range = try Self.parseRange(rangeString: rangeString)
    }

    static func parseRange(rangeString: String) throws -> ClosedRange<Date> {
        let components = rangeString.split(separator: Self.rangeSplitSeparator).map { String($0) }
        if components.count == 2 {
            let startDate = try _parseDate(dateString: components[0], startAtBeginning: true)
            let endDate = try _parseDate(dateString: components[1], startAtBeginning: false)
            return startDate...endDate
        } else if components.count == 1 {
            let dateString = components[0]

            if rangeString.hasPrefix(Self.rangeSplitSeparator) {
                let endDate = try _parseDate(dateString: dateString, startAtBeginning: false)
                return Date(timeIntervalSince1970: 0)...endDate
            } else if rangeString.hasSuffix(Self.rangeSplitSeparator) {
                let startDate = try _parseDate(dateString: dateString, startAtBeginning: true)
                return startDate...Date.currentDate
            } else {
                guard let option = ConvenienceDateOptions(rawValue: dateString) else {
                    throw AppError.invalidInput("unexpected date option: \(dateString)")
                }

                /// Map input like `today` to `today...today` to reuse logic.
                return try parseRange(rangeString: "\(option.rawValue)...\(option.rawValue)")
            }
        }

        throw AppError.invalidInput("unexpected date range format: \(rangeString)")
    }

    private static func _parseDate(dateString: String, startAtBeginning: Bool) throws -> Date {
        if let date = ISO8601DateFormatter().date(from: dateString) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Try full format first: YYYY/MM/DD.
        formatter.dateFormat = "MM/dd/yyyy"
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Try short format: MM/DD (defaults to current year).
        formatter.dateFormat = "MM/dd"
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Try short format: DD (defaults to current month).
        formatter.dateFormat = "dd"
        if let date = formatter.date(from: dateString) {
            return date
        }

        if let date = _parseConvenienceDate(dateString: dateString, startAtBeginning: startAtBeginning) {
            return date
        }

        throw AppError.invalidInput("unexpected date format: \(dateString)")
    }

    private static func _parseConvenienceDate(dateString: String, startAtBeginning: Bool) -> Date? {
        guard let option = ConvenienceDateOptions(rawValue: dateString) else {
            return nil
        }

        let calendar = Calendar.current

        switch option {
        case .today:
            // today... (start of today) ...today (end of today)
            return startAtBeginning ? calendar.startOfDay(for: .currentDate) : .currentDate
        case .yesterday:
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: .currentDate) else {
                return nil
            }

            // yesterday... (start of yesterday) ...yesterday (end of yesterday)
            return startAtBeginning ? calendar.startOfDay(for: yesterday) : yesterday.endOfDay(using: calendar)
        case .thisWeek:
            // thisWeek... (start of this week) ...thisWeek (end of this week)
            let startOfThisWeek = Date.currentDate.thisWeekSunday(startOfDay: true)
            let endOfThisWeek = Date.currentDate
            return startAtBeginning ? startOfThisWeek : endOfThisWeek
        case .lastWeek:
            // lastWeek... (start of last week) ...lastWeek (end of last week)
            let startOfLastWeek = Date.currentDate.lastWeekSunday(startOfDay: true)
            let endOfLastWeek = Date.currentDate.lastWeekSunday(startOfDay: false)
            return startAtBeginning ? startOfLastWeek : endOfLastWeek
        case .thisMonth:
            // thisMonth... (start of this month) ...thisMonth (end of this month)
            let startOfMonth = Date.currentDate.startOfThisMonth(startOfDay: true)
            let endOfThisMonth = Date.currentDate.endOfThisMonth(startOfDay: false)
            return startAtBeginning ? startOfMonth : endOfThisMonth
        case .lastMonth:
            // lastMonth... (start of last month) ...lastMonth (end of last month)
            guard let endOfLastMonth =  Date.currentDate.startOfThisMonth(startOfDay: true)?.addingTimeInterval(-1) else {
                return nil
            }
            let startOfLastMonth = endOfLastMonth.startOfThisMonth(startOfDay: true)
            return startAtBeginning ? startOfLastMonth : endOfLastMonth
        case .thisYear:
            // thisYear... (start of this year) ...thisYear (end of this year)
            let endOfThisYear = Date.currentDate.endOfThisYear(startOfDay: false)
            let startOfThisYear = Date.currentDate.startOfThisYear(startOfDay: true)
            return startAtBeginning ? startOfThisYear : endOfThisYear
        case .lastYear:
            // lastYear... (start of last year) ...lastYear (end of last year)
            guard let endOfLastYear = Date.currentDate.endOfThisYear(startOfDay: false)?.addingTimeInterval(-1) else {
                return nil
            }
            let startOfLastYear = endOfLastYear.startOfThisYear(startOfDay: true)
            return startAtBeginning ? startOfLastYear : endOfLastYear
        }
    }
}
