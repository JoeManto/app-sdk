//
//  Date+Util.swift
//  AppSDK
//
//  Created by Joe Manto on 12/19/25.
//

import Foundation

extension Date {
    public func endOfDay(using calendar: Calendar = .current) -> Date {
        // Get the start of tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self))!
        // Subtract one second to get the last second of the current day
        return calendar.date(byAdding: .second, value: -1, to: tomorrow)!
    }

    public func startOfDay(using calendar: Calendar = .current) -> Date {
        return calendar.startOfDay(for: self)
    }

    public static func yesterday(startOfDay: Bool) -> Date {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!

        if startOfDay {
            return calendar.startOfDay(for: yesterday)
        } else {
            return yesterday.endOfDay(using: calendar)
        }
    }

    public var isSunday: Bool {
        return Calendar.current.component(.weekday, from: self) == 1
    }

    public func previousSunday(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: self)
        let weekday = calendar.component(.weekday, from: today)

        // In Gregorian: Sunday = 1, Saturday = 7
        var daysSincePreviousSunday = (weekday + 6) % 7
        if daysSincePreviousSunday == 0 {
            daysSincePreviousSunday = 7
        }

        guard let previousSunday = calendar.date(byAdding: .day, value: -daysSincePreviousSunday, to: today) else {
            return nil
        }

        if startOfDay {
            return calendar.startOfDay(for: previousSunday)
        } else {
            return previousSunday.endOfDay(using: calendar)
        }
    }

    public func thisWeekSunday(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current

        var thisSunday = self
        if !isSunday {
            // Get last Sunday's date (this week's Sunday)
            guard let sunday = self.previousSunday(startOfDay: true) else {
                return nil
            }
            thisSunday = sunday
        }

        if startOfDay {
            return calendar.startOfDay(for: thisSunday)
        } else {
            return thisSunday.endOfDay(using: calendar)
        }
    }

    public func lastWeekSunday(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current

        var thisSunday = self
        if !isSunday {
            // Get last Sunday's date (this week's Sunday)
            guard let sunday = self.previousSunday(startOfDay: true) else {
                return nil
            }
            thisSunday = sunday
        }

        // Subtract 7 days to get the previous (last week's) Sunday
        guard let lastWeekSunday = calendar.date(byAdding: .day, value: -7, to: thisSunday) else {
            return nil
        }

        if startOfDay {
            return calendar.startOfDay(for: lastWeekSunday)
        } else {
            return lastWeekSunday.endOfDay(using: calendar) ?? lastWeekSunday
        }
    }

    public func nextSunday(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: self)
        let weekday = calendar.component(.weekday, from: today)
        // Days until next Sunday (including today if it's Sunday)
        let daysUntilNextSunday = (8 - weekday) % 7
        guard let nextSunday = calendar.date(byAdding: .day, value: daysUntilNextSunday == 0 ? 7 : daysUntilNextSunday, to: today) else {
            return nil
        }
        if startOfDay {
            return nextSunday.startOfDay()
        } else {
            return nextSunday.endOfDay()
        }
    }

    public func startOfThisMonth(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return nil
        }

        if startOfDay {
            return startOfMonth.startOfDay()
        } else {
            return startOfMonth.endOfDay()
        }
    }

    public func endOfThisMonth(startOfDay: Bool) -> Date? {
        guard let startOfMonth = startOfThisMonth(startOfDay: true) else {
            return nil
        }

        var components = DateComponents()
        components.month = 1
        guard let date = Calendar.current.date(byAdding: components, to: startOfMonth)?.addingTimeInterval(-1) else {
            return nil
        }

        if startOfDay {
            return date.startOfDay()
        } else {
            return date.endOfDay()
        }
    }

    public func startOfThisYear(startOfDay: Bool) -> Date? {
        let calendar = Calendar.current

        guard let date = calendar.date(from: calendar.dateComponents([.year], from: self)) else {
            return nil
        }

        if startOfDay {
            return date.startOfDay()
        } else {
            return date.endOfDay()
        }
    }

    public func endOfThisYear(startOfDay: Bool) -> Date? {
        guard let startOfYear = startOfThisYear(startOfDay: true) else {
            return nil
        }

        var components = DateComponents()
        components.year = 1
        guard let date = Calendar.current.date(byAdding: components, to: startOfYear)?.addingTimeInterval(-1) else {
            return nil
        }

        if startOfDay {
            return date.startOfDay()
        } else {
            return date.endOfDay()
        }
    }
}
