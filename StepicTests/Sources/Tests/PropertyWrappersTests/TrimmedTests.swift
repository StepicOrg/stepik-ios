@testable
import Stepic

import XCTest

final class TrimmedTests: XCTestCase {
    @Trimmed
    var text = ""

    override func setUp() {
        _text = Trimmed(wrappedValue: "   Hello, World! \n   \n")
    }

    func testGet() {
        XCTAssertEqual(text, "Hello, World!")
    }

    func testSet() {
        text = " \n Hi       \n"
        XCTAssertEqual(text, "Hi")
    }
}
