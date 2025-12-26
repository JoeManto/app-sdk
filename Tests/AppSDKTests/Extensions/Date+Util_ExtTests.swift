//
//  Date+Util_ExtTests.swift
//  AppSDK
//
//  Created by Joe Manto on 12/25/25.
//

import Foundation
import Testing
@testable import AppSDK

@Suite("Date+Util Extension Tests")
struct DateUtil_ExtTests {

    // MARK: - Helper

    /// Creates a date from components using the current calendar for consistency with source code
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second))!
    }

    private var calendar: Calendar { Calendar.current }

    // MARK: - Start/End of Day

    @Test("startOfDay returns midnight, endOfDay returns 23:59:59")
    func dayBoundaries() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 14, minute: 30, second: 45)

        let start = date.startOfDay()
        let end = date.endOfDay()

        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: start)
        #expect(startComponents.hour == 0)
        #expect(startComponents.minute == 0)
        #expect(startComponents.second == 0)

        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: end)
        #expect(endComponents.hour == 23)
        #expect(endComponents.minute == 59)
        #expect(endComponents.second == 59)
    }

    // MARK: - Day of Week

    @Test("dayOfWeek correctly identifies each weekday", arguments: [
        (2025, 12, 21, Date.DayOfWeek.sunday),    // Sunday
        (2025, 12, 22, Date.DayOfWeek.monday),    // Monday
        (2025, 12, 23, Date.DayOfWeek.tuesday),   // Tuesday
        (2025, 12, 24, Date.DayOfWeek.wednesday), // Wednesday
        (2025, 12, 25, Date.DayOfWeek.thursday),  // Thursday
        (2025, 12, 26, Date.DayOfWeek.friday),    // Friday
        (2025, 12, 27, Date.DayOfWeek.saturday)   // Saturday
    ])
    func dayOfWeek(year: Int, month: Int, day: Int, expected: Date.DayOfWeek) {
        let date = makeDate(year: year, month: month, day: day)
        #expect(date.dayOfWeek == expected)
    }

    @Test("isSunday returns true only for Sundays")
    func isSunday() {
        let sunday = makeDate(year: 2025, month: 12, day: 21)
        let monday = makeDate(year: 2025, month: 12, day: 22)

        #expect(sunday.isSunday == true)
        #expect(monday.isSunday == false)
    }

    // MARK: - Sunday Navigation

    @Test("previousSunday finds the most recent past Sunday")
    func previousSunday() {
        // Thursday Dec 25, 2025 -> should return Sunday Dec 21
        let thursday = makeDate(year: 2025, month: 12, day: 25)
        let result = thursday.previousSunday(startOfDay: true)

        #expect(result != nil)
        let components = calendar.dateComponents([.year, .month, .day], from: result!)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)

        // From Sunday, should return the previous Sunday (7 days back)
        let sunday = makeDate(year: 2025, month: 12, day: 21)
        let sundayResult = sunday.previousSunday(startOfDay: true)
        let sundayComponents = calendar.dateComponents([.day], from: sundayResult!)
        #expect(sundayComponents.day == 14)
    }

    @Test("thisWeekSunday returns current week's Sunday")
    func thisWeekSunday() {
        // Wednesday Dec 25, 2025 -> should return Sunday Dec 21, 2025 (this week's Sunday)
        let wednesday = makeDate(year: 2025, month: 12, day: 25)
        let result = wednesday.thisWeekSunday(startOfDay: true)

        #expect(result != nil)
        let components = calendar.dateComponents([.year, .month, .day], from: result!)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)

        // Sunday should return itself
        let sunday = makeDate(year: 2025, month: 12, day: 21)
        let sundayResult = sunday.thisWeekSunday(startOfDay: true)
        let sundayComponents = calendar.dateComponents([.year, .month, .day], from: sundayResult!)
        #expect(sundayComponents.day == 21)
    }

    @Test("nextSunday returns the following Sunday")
    func nextSunday() {
        // Wednesday Dec 25, 2025 -> should return Sunday Dec 28, 2025
        let wednesday = makeDate(year: 2025, month: 12, day: 25)
        let result = wednesday.nextSunday(startOfDay: true)

        #expect(result != nil)
        let components = calendar.dateComponents([.year, .month, .day], from: result!)
        #expect(components.day == 28)

        // Sunday should return the *next* Sunday (7 days later)
        let sunday = makeDate(year: 2025, month: 12, day: 21)
        let sundayResult = sunday.nextSunday(startOfDay: true)
        let sundayComponents = calendar.dateComponents([.year, .month, .day], from: sundayResult!)
        #expect(sundayComponents.day == 28)
    }

    // MARK: - Next Week Day of Week

    @Test("nextWeekDayOfWeek returns correct day in the following week", arguments: [
        (Date.DayOfWeek.sunday, 28),
        (Date.DayOfWeek.monday, 29),
        (Date.DayOfWeek.tuesday, 30),
        (Date.DayOfWeek.wednesday, 31),
        (Date.DayOfWeek.thursday, 1),  // Jan 1, 2026
        (Date.DayOfWeek.friday, 2),
        (Date.DayOfWeek.saturday, 3)
    ])
    func nextWeekDayOfWeek(dayOfWeek: Date.DayOfWeek, expectedDay: Int) {
        // From Wednesday Dec 25, 2025
        let wednesday = makeDate(year: 2025, month: 12, day: 25)
        let result = wednesday.nextWeekDayOfWeek(dayOfWeek, startOfDay: true)

        #expect(result != nil)
        let components = calendar.dateComponents([.day], from: result!)
        #expect(components.day == expectedDay)
    }

    // MARK: - Month Boundaries

    @Test("startOfThisMonth and endOfThisMonth return correct dates")
    func monthBoundaries() {
        // Mid-February 2025 (non-leap year, 28 days)
        let february = makeDate(year: 2025, month: 2, day: 15)

        let startOfMonth = february.startOfThisMonth(startOfDay: true)
        #expect(startOfMonth != nil)
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startOfMonth!)
        #expect(startComponents.month == 2)
        #expect(startComponents.day == 1)

        let endOfMonth = february.endOfThisMonth(startOfDay: false)
        #expect(endOfMonth != nil)
        let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endOfMonth!)
        #expect(endComponents.month == 2)
        #expect(endComponents.day == 28)
        #expect(endComponents.hour == 23)
        #expect(endComponents.minute == 59)
        #expect(endComponents.second == 59)
    }

    // MARK: - Year Boundaries

    @Test("startOfThisYear and endOfThisYear return correct dates")
    func yearBoundaries() {
        let midYear = makeDate(year: 2025, month: 6, day: 15)

        let startOfYear = midYear.startOfThisYear(startOfDay: true)
        #expect(startOfYear != nil)
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startOfYear!)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)

        let endOfYear = midYear.endOfThisYear(startOfDay: false)
        #expect(endOfYear != nil)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: endOfYear!)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }
}
