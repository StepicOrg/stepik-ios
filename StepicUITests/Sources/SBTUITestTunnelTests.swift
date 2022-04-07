import SBTUITestTunnelClient
import XCTest

class SBTUITestTunnelTests: XCTestCase {
    override func setUp() {
        super.setUp()

        self.continueAfterFailure = false
        self.app.launchTunnel()
    }

    func testCustomCodeBlockWorks() throws {
        sleep(2)

        let objectToInject = "test"
        let objectReturnedByBlock = self.app.performCustomCommandNamed("myCustomCommandKey", object: objectToInject)

        guard let number = objectReturnedByBlock as? NSNumber else {
            fatalError("invalid return type")
        }

        XCTAssertTrue(number.boolValue)
    }

    func testOpenCourseDeepLinkViaCustomCodeBlock() throws {
        sleep(2)

        let objectReturnedByBlock = self.app.performCustomCommandNamed(
            "openDeepLink",
            object: "https://stepik.org/course/58852"
        )

        XCTAssertNotNil(objectReturnedByBlock)

        guard let number = objectReturnedByBlock as? NSNumber else {
            fatalError("invalid return type")
        }

        XCTAssertTrue(number.boolValue)
        XCTAssertTrue(self.app.navigationBars.matching(identifier: "About course").element.waitForExistence(timeout: 5))
    }
}
