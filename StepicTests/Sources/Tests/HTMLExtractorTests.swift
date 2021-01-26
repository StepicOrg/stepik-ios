@testable
import Stepic

import XCTest

final class HTMLExtractorTests: XCTestCase {
    func testThatHTMLExtractorNotCrashesWhenParsingStringWithWhitespacesAndNewlines() {
        // Given
        let characterSet = CharacterSet.whitespacesAndNewlines
        var characters = [Character]()
        for plane: UInt8 in 0...16 where characterSet.hasMember(inPlane: plane) {
            for unicode in UInt32(plane) << 16 ..< UInt32(plane + 1) << 16 {
                if let uniChar = UnicodeScalar(unicode), characterSet.contains(uniChar) {
                    characters.append(Character(uniChar))
                }
            }
        }
        let strings = characters.map { String($0) }

        let extractorType: HTMLExtractorProtocol.Type = HTMLExtractor.self

        // When
        let results = strings.map { string in
            extractorType.extractAllTagsAttribute(tag: "a", attribute: "href", from: string)
        }

        // Then
        results.forEach { result in
            XCTAssertEqual(result, [])
        }
    }
}
