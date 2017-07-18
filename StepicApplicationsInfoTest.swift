//
//  ApplicationsInfoTest.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import XCTest
@testable import Stepic

class StepicApplicationsInfoTest: XCTestCase {
    // Copy-paste from old file
    static let urlScheme = "stepic"
    
    static let apiURL = "https://stepik.org/api"
    static let oauthURL = "https://stepik.org/oauth2"
    static let stepicURL = "https://stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
    
    static let cookiePrefix = ""
    
    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
    
    static let streaksEnabled = true
    static let shouldRegisterNotifications = true
    
    static let isAdaptive = false
    
    struct RateApp {
        static let correctSubmissionsThreshold = 4
        static let appStoreURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1064581926&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&action=write-review")
    }
    
    struct SocialInfo {
        struct AppIds {
            static let vk = "5628680"
            static let facebook = "171127739724012"
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAppConf() {
        // There are all values from StepicApplicationsInfo in main app
        XCTAssertEqual(StepicApplicationsInfo.urlScheme, StepicApplicationsInfoTest.urlScheme)
        XCTAssertEqual(StepicApplicationsInfo.apiURL, StepicApplicationsInfoTest.apiURL)
        XCTAssertEqual(StepicApplicationsInfo.oauthURL, StepicApplicationsInfoTest.oauthURL)
        XCTAssertEqual(StepicApplicationsInfo.stepicURL, StepicApplicationsInfoTest.stepicURL)
        XCTAssertEqual(StepicApplicationsInfo.versionInfoURL, StepicApplicationsInfoTest.versionInfoURL)
        XCTAssertEqual(StepicApplicationsInfo.cookiePrefix, StepicApplicationsInfoTest.cookiePrefix)
        XCTAssertEqual(StepicApplicationsInfo.doesAllowCourseUnenrollment, StepicApplicationsInfoTest.doesAllowCourseUnenrollment)
        XCTAssertEqual(StepicApplicationsInfo.inAppUpdatesAvailable, StepicApplicationsInfoTest.inAppUpdatesAvailable)
        XCTAssertEqual(StepicApplicationsInfo.streaksEnabled, StepicApplicationsInfoTest.streaksEnabled)
        XCTAssertEqual(StepicApplicationsInfo.shouldRegisterNotifications, StepicApplicationsInfoTest.shouldRegisterNotifications)
        XCTAssertEqual(StepicApplicationsInfo.isAdaptive, StepicApplicationsInfoTest.isAdaptive)
        XCTAssertEqual(StepicApplicationsInfo.RateApp.correctSubmissionsThreshold, StepicApplicationsInfoTest.RateApp.correctSubmissionsThreshold)
        XCTAssertEqual(StepicApplicationsInfo.RateApp.appStoreURL, StepicApplicationsInfoTest.RateApp.appStoreURL)
        XCTAssertEqual(StepicApplicationsInfo.SocialInfo.AppIds.vk, StepicApplicationsInfoTest.SocialInfo.AppIds.vk)
        XCTAssertEqual(StepicApplicationsInfo.SocialInfo.AppIds.facebook, StepicApplicationsInfoTest.SocialInfo.AppIds.facebook)
    }
 
}
