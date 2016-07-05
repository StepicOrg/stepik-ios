//
//  DiscussionsAPITests.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest 
import UIKit
@testable import Stepic

class DiscussionsAPITests : XCTestCase {
    
    let comments = CommentsAPI()
    let discussionProxies = DiscussionProxiesAPI()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetDiscussions() {
        let expectation = expectationWithDescription("testGetDiscussions")
        let discussionProxyId = "77-108896"
        discussionProxies.retrieve(discussionProxyId, success: 
            {
                discussionProxy in
                self.comments.retrieve(discussionProxy.discussionIds, success: 
                    { 
                        comments in
                        expectation.fulfill()
                    }, error: 
                    {
                        errorString in
                        XCTAssert(false, errorString)
                    }
                )       
            }, error: {
                errorString in
                XCTAssert(false, errorString)
            }
        )
        
        waitForExpectationsWithTimeout(10.0) { 
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }
    }
    
    func testCreateComment() {
        let expectation = expectationWithDescription("testCreateComment")
        let discussionProxyId = "77-108896"
        let target = 108896
        let postable = CommentPostable(target: target, text: "testCreateComment comment")
        comments.create(postable, success: 
            {
                comment in
                self.discussionProxies.retrieve(discussionProxyId, success: 
                    {
                        discussionProxy in
                        if discussionProxy.discussionIds.indexOf(comment.id) == nil {
                            XCTAssert(false, "Created discussion not found")
                        }
                        expectation.fulfill()
                    }, error: 
                    {
                        errorString in
                        XCTAssert(false, errorString)
                    }
                )
            }, error: {
                errorString in
                XCTAssert(false, errorString)
            }
        )
        
        waitForExpectationsWithTimeout(10.0) { 
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }
    }
    
    func testCreateReply() {
        let expectation = expectationWithDescription("testCreateReply")
        let target = 108896
        let parent = 226119
        let postable = CommentPostable(parent: parent, target: target, text: "testCreateReply comment")
        comments.create(postable, success: 
            {
                comment in
                self.comments.retrieve([parent], success: 
                    {
                        parentcomment in
                        if parentcomment[0].repliesIds.indexOf(comment.id) == nil {
                            XCTAssert(false, "Created reply not found")
                        }
                        expectation.fulfill()
                    }, error: 
                    {
                        errorString in
                        XCTAssert(false, errorString)
                    }
                )
            }, error: {
                errorString in
                XCTAssert(false, errorString)
            }
        )
        
        waitForExpectationsWithTimeout(10.0) { 
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }

    }
}

