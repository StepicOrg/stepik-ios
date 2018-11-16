//
// CourseInfoTabInfoBlockResourcesTests.swift
// stepik-ios
//
// Created by Ivan Magda on 11/16/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import XCTest

@testable import Stepic

class CourseInfoTabInfoBlockResourcesTests: XCTestCase {
    private static let allCases: [CourseInfoTabInfoView.Block] = [
        .author,
        .introVideo,
        .about,
        .requirements,
        .targetAudience,
        .instructors,
        .timeToComplete,
        .language,
        .certificate,
        .certificateDetails
    ]

    func testBlockTitleResources() {
        for block in CourseInfoTabInfoBlockResourcesTests.allCases {
            switch block {
            case .author:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleAuthor", comment: ""))
            case .introVideo:
                XCTAssertEqual(block.title, "")
            case .about:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleAbout", comment: ""))
            case .requirements:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleRequirements", comment: ""))
            case .targetAudience:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleTargetAudience", comment: ""))
            case .instructors:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleInstructors", comment: ""))
            case .timeToComplete:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleTimeToComplete", comment: ""))
            case .language:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleLanguage", comment: ""))
            case .certificate:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleCertificate", comment: ""))
            case .certificateDetails:
                XCTAssertEqual(block.title, NSLocalizedString("CourseInfoTitleCertificateDetails", comment: ""))
            }
        }
    }

    func testBlockIconResources() {
        for block in CourseInfoTabInfoBlockResourcesTests.allCases {
            switch block {
            case .author:
                XCTAssertNotNil(block.icon)
            case .introVideo:
                XCTAssertNil(block.icon)
            case .about:
                XCTAssertNotNil(block.icon)
            case .requirements:
                XCTAssertNotNil(block.icon)
            case .targetAudience:
                XCTAssertNotNil(block.icon)
            case .instructors:
                XCTAssertNotNil(block.icon)
            case .timeToComplete:
                XCTAssertNotNil(block.icon)
            case .language:
                XCTAssertNotNil(block.icon)
            case .certificate:
                XCTAssertNotNil(block.icon)
            case .certificateDetails:
                XCTAssertNotNil(block.icon)
            }
        }
    }
}
