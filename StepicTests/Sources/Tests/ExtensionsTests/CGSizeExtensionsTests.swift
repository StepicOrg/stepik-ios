@testable
import Stepic

import XCTest

final class CGSizeExtensionsTests: XCTestCase {
    func testMultiplyScalar() {
        let size = CGSize(width: 4, height: 5)
        let result = size * 2
        XCTAssertEqual(result.width, 8)
        XCTAssertEqual(result.height, 10)
    }
}
