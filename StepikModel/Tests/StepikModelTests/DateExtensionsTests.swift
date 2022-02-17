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
}
