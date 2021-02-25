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

    func testThatHTMLExtractorAPIIsSafe() {
        let content = """
                    <html>
                    <head>
                        <title>test title</title>
                    </head>
                    <body>
                        <a href="https://www.google.com/">google</a>
                        <img alt="" src="https://ucarecdn.com/57ea9a4e-b8a9-4d14-9748-d1851cc58247/" width="70" />
                        <p><img alt="" src="https://ucarecdn.com/983dc5db-6cc1-45bd-9f9b-5d787a3be48c/" /></p>
                    </body>
                    </html>
                    """

        let extractorType: HTMLExtractorProtocol.Type = HTMLExtractor.self

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                let links = extractorType.extractAllTagsAttribute(tag: "a", attribute: "href", from: content)

                XCTAssertTrue(links.count == 1)
                XCTAssertEqual(links, ["https://www.google.com/"])
            }

            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                let contents = extractorType.extractAllTagsContent(tag: "title", from: content)

                XCTAssertTrue(contents.count == 1)
                XCTAssertEqual(contents, ["test title"])
            }

            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                let images = extractorType.extractAllTags(tag: "img", from: content)

                XCTAssertTrue(images.count == 2)
                XCTAssertEqual(
                    images[0],
                    "<img alt=\"\" src=\"https://ucarecdn.com/57ea9a4e-b8a9-4d14-9748-d1851cc58247/\" width=\"70\">"
                )
                XCTAssertEqual(
                    images[1],
                    "<img alt=\"\" src=\"https://ucarecdn.com/983dc5db-6cc1-45bd-9f9b-5d787a3be48c/\">"
                )
            }
        }
    }
}
