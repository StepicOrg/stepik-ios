@testable
import Stepic

import XCTest

final class HTMLExtractorTests: XCTestCase {
    func testThatHTMLExtractorNotCrashesWhenParsingStringWithWhitespace() {
        // Given
        let value = " "
        let extractorType: HTMLExtractorProtocol.Type = HTMLExtractor.self

        // When
        let res = extractorType.extractAllTagsAttribute(tag: "a", attribute: "href", from: value)

        // Then
        XCTAssertEqual(res, [])
    }
}
