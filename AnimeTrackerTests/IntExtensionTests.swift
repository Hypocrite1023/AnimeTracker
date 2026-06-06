//
//  IntExtensionTests.swift
//  AnimeTrackerTests
//
//  Created by Rex Chiu on 2026/1/19.
//

import XCTest
@testable import AnimeTracker

final class IntExtensionTests: XCTestCase {

    func testMakeTimeString() {
        XCTAssertEqual(100.makeTimeString(), "1M")
        XCTAssertEqual(60.makeTimeString(), "1M")
        XCTAssertEqual(59.makeTimeString(), "59S")
        XCTAssertEqual(3661.makeTimeString(), "1H1M")
        XCTAssertEqual(86400.makeTimeString(), "1D")
        XCTAssertEqual(0.makeTimeString(), "0 second")
        XCTAssertEqual(90061.makeTimeString(), "1D1H1M")
    }

}
