//
//  String_ExtTests.swift
//
//
//  Created by Joe Manto on 7/23/23.
//

import Foundation
import XCTest

final class String_ExtTests: XCTestCase {

    var colors: [NSColor] {
        [NSColor.white, .orange, .blue, .red, .green, .brown, .clear].map {
            $0.usingColorSpace(.deviceRGB)!
        }
    }
    
    var hexs: [String] {
        ["FFFFFF", "FF7F00", "0000FF", "FF0000", "00FF00", "996633", "000000"]
    }
    
    func testToHex() throws {
        for (i, color) in self.colors.enumerated() {
            XCTAssertEqual(color.toHexString, self.hexs[i])
        }
    }
    
    func testHexToColor() throws {
        for (_, hex) in self.hexs.enumerated() {
            let color = try XCTUnwrap(NSColor.hex(hex, alpha: 1.0).usingColorSpace(.deviceRGB))
            XCTAssertEqual(color.toHexString, hex)
        }
    }

    func testNoPadding() {
        var string = " hello world "
        XCTAssertEqual(string.noPadding, "hello world")

        string = "      hello world"
        XCTAssertEqual(string.noPadding, "hello world")

        string = "hello world      "
        XCTAssertEqual(string.noPadding, "hello world")

        string = "      hello world      "
        XCTAssertEqual(string.noPadding, "hello world")

        string = "      hello       world      "
        XCTAssertEqual(string.noPadding, "hello       world")

        string = "     | hello world |     "
        XCTAssertEqual(string.noPadding, "| hello world |")

        string = ""
        XCTAssertEqual(string.noPadding, "")

        string = "a"
        XCTAssertEqual(string.noPadding, "a")

        string = "a "
        XCTAssertEqual(string.noPadding, "a")

        string = " a"
        XCTAssertEqual(string.noPadding, "a")
    }
}

