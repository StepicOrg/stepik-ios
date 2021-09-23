@testable
import Stepic

import Foundation
import Nimble
import Quick

class PlatformTypeSpec: QuickSpec {
    override func spec() {
        describe("PlatformOptionSet") {
            it("correctly merges single option into a single string") {
                let platforms: PlatformOptionSet = [.web]
                expect(platforms.stringValue) == "web"
            }

            it("correctly merges two options into a single string") {
                let platforms: PlatformOptionSet = [.mobile, .web]
                expect(platforms.stringValue) == "web,mobile"
            }

            it("correctly merges mobileIOS option into a single string") {
                let platforms = PlatformOptionSet.mobileIOS
                expect(platforms.stringValue) == "mobile,ios"
            }
        }
    }
}
