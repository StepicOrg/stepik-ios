@testable
import Stepic

import Alamofire
import Nimble
import XCTest

class UserAgentTests: XCTestCase {
    func testAPIEndpointManagerUserAgent() {
        let endpoint = APIEndpoint()
        let headers = endpoint.manager.session.configuration.httpAdditionalHeaders
        let userAgent = headers?["User-Agent"] as? String

        expect(userAgent).to(contain("com.AlexKarpov.Stepic"))
    }

    func testSharedManagerUserAgent() {
        let headers = AlamofireDefaultSessionManager.shared.session.configuration.httpAdditionalHeaders
        let userAgent = headers?["User-Agent"] as? String

        expect(userAgent).to(contain("com.AlexKarpov.Stepic"))
    }
}
