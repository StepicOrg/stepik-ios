@testable
import StepikModel

import XCTest

final class DateExtensionsTests: XCTestCase {
    func testParsesDateStrings() throws {
        // Given
        let dateStrings = [
            "2021-05-04T10:21:43.571Z",
            "2021-06-07T16:13:25.147Z"
        ]

        // When
        let dates = dateStrings.compactMap(DateFormatter.parsedStepikISO8601Date(from:))

        // Then
        XCTAssert(!dates.isEmpty, "Expected not empty array of dates")
    }

    func testStepikISO8601ShortStringRepresentation() throws {
        // Given
        let dates = [
            DateFormatter.parsedStepikISO8601Date(from: "2021-05-04T10:21:43.571Z")!,
            DateFormatter.parsedStepikISO8601Date(from: "2021-06-07T16:13:25.147Z")!
        ]

        // When
        let datesStrings = dates.map(DateFormatter.stepikISO8601MediumString(from:))

        // Then
        XCTAssertEqual(datesStrings[0], "2021-05-04T10:21:43.571Z")
        XCTAssertEqual(datesStrings[1], "2021-06-07T16:13:25.147Z")
    }
}
