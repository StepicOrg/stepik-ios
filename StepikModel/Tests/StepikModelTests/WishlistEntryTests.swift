@testable
import StepikModel

import XCTest

final class WishlistEntryTests: XCTestCase {
    func testDeserializeJSON() throws {
        // Given
        let jsonString = """
        {
          "id": 626257,
          "user": 21612976,
          "course": 5482,
          "create_date": "2022-02-03T07:59:56.095Z",
          "platform": "web"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let wishlistEntry = try decoder.decode(WishlistEntry.self, from: jsonData)

        // Then
        XCTAssertEqual(wishlistEntry.id, 626257)
        XCTAssertEqual(wishlistEntry.userID, 21612976)
        XCTAssertEqual(wishlistEntry.courseID, 5482)
        XCTAssertNotNil(wishlistEntry.createDate)
        XCTAssertEqual(wishlistEntry.platform, "web")
    }
}
