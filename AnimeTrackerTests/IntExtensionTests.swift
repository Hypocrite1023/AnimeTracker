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
        XCTAssertEqual(100.makeTimeString(), "1min40sec")
        XCTAssertEqual(60.makeTimeString(), "1min")
        XCTAssertEqual(59.makeTimeString(), "59sec")
        XCTAssertEqual(3661.makeTimeString(), "1hr1min1sec")
        XCTAssertEqual(86400.makeTimeString(), "1day")
        XCTAssertEqual(0.makeTimeString(), "0sec")
        XCTAssertEqual(90061.makeTimeString(), "1day1hr1min1sec")
    }

}
