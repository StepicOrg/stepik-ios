//
//  UserAgentTests.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.04.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import Nimble
import Alamofire
import XCTest
@testable import Stepic

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
