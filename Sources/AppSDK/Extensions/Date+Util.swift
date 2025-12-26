//
//  Date+Util.swift
//  AppSDK
//
//  Created by Joe Manto on 12/19/25.
//

import Foundation

extension Date {


    /// Represents the days of the week, with raw values matching the `Calendar.Component.weekday`.
    ///
    /// Use this enum to safely refer to days of the week when working with calendar-based date calculations.
    public enum DayOfWeek: Int {
        case sunday = 1
        case monday, tuesday, wednesday, thursday, friday, saturday
    }

    /// Returns a `Date` representing the last second of the current day.
    ///
    /// This method calculates the end of the day (23:59:59) for the callers date.
    ///
    /// - Parameter calendar: The `Calendar` to use for calculations. Defaults to `.current`.
    /// - Returns: A `Date` representing the last moment of the receiver's day.
    public func endOfDay(using calendar: Calendar = .current) -> Date {
        // Get the start of tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self))!
        // Subtract one second to get the last second of the current day
        return calendar.date(byAdding: .second, value: -1, to: tomorrow)!
    }

    /// Returns a `Date` representing the start of the day for the caller.
    ///
    /// This method calculates the beginning of the day (00:00:00) for the date instance,
    ///
    /// - Parameter calendar: The `Calendar` to use for calculations. Defaults to `.current`.
    /// - Returns: A `Date` representing the first moment of the receiver's day.
    public func startOfDay(using calendar: Calendar = .current) -> Date {
        return calendar.startOfDay(for: self)
    }

    /// Returns a `Date` representing yesterday, either at the start or end of the day.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of yesterday (`true` for 00:00:00)
    ///   or the end of yesterday (`false` for 23:59:59).
    /// - Returns: A `Date` representing the desired moment of yesterday.
    public static func yesterday(startOfDay: Bool) -> Date {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!

        if startOfDay {
            return calendar.startOfDay(for: yesterday)
        } else {
            return yesterday.endOfDay(using: calendar)
        }
    }

    /// A Boolean value indicating whether the date falls on a Sunday.
    ///
    /// This property uses the current calendar to determine if the receiver's weekday
    /// is Sunday.
    ///
    /// - Returns: `true` if the date is a Sunday; otherwise, `false`.
    public var isSunday: Bool {
        // In the Gregorian calendar, Sunday is represented by the value `1`.
        return Calendar.current.component(.weekday, from: self) == 1
    }

    /// Returns the day of the week for the receiver as a `DayOfWeek` value.
    ///
    /// - Returns: A `DayOfWeek` representing the weekday of the receiver.
    var dayOfWeek: DayOfWeek {
        let rawValue = Calendar.current.dateComponents([.weekday], from: self).weekday!
        return DayOfWeek(rawValue: rawValue)!
    }

    /// Returns a `Date` representing the previous Sunday relative to the receiver.
    ///
    /// This method calculates the date of the most recent Sunday before (or on) the receiver's date,
    /// and returns either the start or end of that day, depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of the previous Sunday (`true` for 00:00:00)
    ///   or the end of the previous Sunday (`false` for 23:59:59).
    /// - Returns: An optional `Date` representing the desired moment of the previous Sunday, or `nil` if the calculation fails.
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

    /// Returns the date for Sunday of the current week relative to the receiver.
    ///
    /// This method calculates the Sunday of the week containing the receiver's date. If the receiver already falls on a Sunday,
    /// it is returned directly; otherwise, the most recent past Sunday is returned. The returned date can be set either to the 
    /// start or end of that Sunday, depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: If `true`, returns the start of Sunday (00:00:00); if `false`, returns the end of Sunday (23:59:59).
    /// - Returns: A `Date` representing this week's Sunday, either at the start or end of the day, or `nil` if the calculation fails.
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

    /// Returns the date for the previous Sunday of the week before the receiver's week.
    ///
    /// This method calculates the Sunday of the week preceding the one containing the receiver's date.
    /// If the receiver falls on a Sunday, that date is considered this week's Sunday, and the method finds the Sunday of the previous week.
    /// The returned date can be set to either the start or end of that Sunday, depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: If `true`, returns the start of Sunday (00:00:00); if `false`, returns the end of Sunday (23:59:59).
    /// - Returns: A `Date` representing last week's Sunday, either at the start or end of the day, or `nil` if the calculation fails.
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

    /// Returns the date for the next Sunday after the receiver.
    ///
    /// This method calculates the date of the next Sunday following the receiver's date.
    /// If the receiver already falls on a Sunday, it returns the following Sunday's date.
    /// The returned date can be set either to the start or end of that Sunday, depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: If `true`, returns the start of Sunday (00:00:00); if `false`, returns the end of Sunday (23:59:59).
    /// - Returns: An optional `Date` representing the next Sunday's date, either at the start or end of the day, or `nil` if the calculation fails.
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

    /// Returns a `Date` representing the next occurrence of the specified day of the week after the receiver.
    ///
    /// This method calculates the date of the next specified weekday (`DayOfWeek`) after the receiver's date, based on the current calendar.
    /// For example, calling this method with `.monday` will return the next week's Monday following the receiver's date.
    /// The returned date can be set to either the start or end of that day, depending on the `startOfDay` parameter.
    ///
    /// - Parameters:
    ///   - dayOfWeek: The `DayOfWeek` value representing the desired next weekday (e.g., `.monday`, `.tuesday`).
    ///   - startOfDay: A Boolean value indicating whether to return the start of the day (`true` for 00:00:00) or the end of the day (`false` for 23:59:59).
    /// - Returns: An optional `Date` representing the next occurrence of the specified day of the week, either at the start or end of that day, or `nil` if the calculation fails.
    public func nextWeekDayOfWeek(_ dayOfWeek: DayOfWeek, startOfDay: Bool) -> Date? {
        guard let nextSunday = self.nextSunday(startOfDay: true) else {
            return nil
        }

        let date = Calendar.current.date(byAdding: .day, value: dayOfWeek.rawValue - 1, to: nextSunday)

        if startOfDay {
            return date?.startOfDay()
        } else {
            return date?.endOfDay()
        }
    }

    /// Returns the date representing the start of this month, either at the beginning or end of the day.
    ///
    /// This method calculates the first day of the month for the receiver’s date. 
    /// The returned date can be set to either the start of that day (00:00:00) or the end of that day (23:59:59), 
    /// depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of the month (00:00:00) 
    ///   or the end of the first day of the month (23:59:59).
    /// - Returns: An optional `Date` representing the desired moment at the beginning of the month, or `nil` if the calculation fails.
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

    /// Returns the date representing the end of this month, either at the beginning or end of the day.
    ///
    /// This method calculates the last day of the month for the receiver’s date. 
    /// The returned date can be set to either the start of that day (00:00:00) or the end of that day (23:59:59),
    /// depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of the last day of the month (00:00:00)
    ///   or the end of the last day of the month (23:59:59).
    /// - Returns: An optional `Date` representing the desired moment at the end of the month, or `nil` if the calculation fails.
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

    /// Returns the date representing the start of this year, either at the beginning or end of the day.
    ///
    /// This method calculates the first day of the year for the receiver’s date.
    /// The returned date can be set to either the start of that day (00:00:00) or the end of that day (23:59:59),
    /// depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of the year (00:00:00)
    ///   or the end of the first day of the year (23:59:59).
    /// - Returns: An optional `Date` representing the desired moment at the beginning of the year,
    ///   or `nil` if the calculation fails.
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

    /// Returns the date representing the end of this year, either at the beginning or end of the day.
    ///
    /// This method calculates the last day of the year for the receiver’s date.
    /// The returned date can be set to either the start of that day (00:00:00) or the end of that day (23:59:59),
    /// depending on the `startOfDay` parameter.
    ///
    /// - Parameter startOfDay: A Boolean value indicating whether to return the start of the last day of the year (00:00:00)
    ///   or the end of the last day of the year (23:59:59).
    /// - Returns: An optional `Date` representing the desired moment at the end of the year, or `nil` if the calculation fails.
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
