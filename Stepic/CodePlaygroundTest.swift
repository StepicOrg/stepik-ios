//
//  CodePlaygroundTest.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import XCTest
@testable import Stepic

class CodePlaygroundTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSubstringChanges() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let manager = CodePlaygroundManager()
        //result - insertion, c
        let changes1 = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abdefg")
        
        //result - insertion, a
        let changes2 = manager.getChangesSubstring(currentText: "abcdefg", previousText: "bcdefg")
        
        //result - insertion, g
        let changes3 = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcdef")
        
        //result - insertion, ddddddde
        let changes4 = manager.getChangesSubstring(currentText: "abcddddddddeefg", previousText: "abcdefg")
        
        //result - deletion, ddddddde
        let changes5 = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcddddddddeefg")
        
        //result - insertion, aaaa
        let changes6 = manager.getChangesSubstring(currentText: "aaaaabc", previousText: "abc")
        
        //result - deletion, lotsoftext
        let changes7 = manager.getChangesSubstring(currentText: "", previousText: "lotsoftext")
        
        //result - insertion, cccc
        let changes8 = manager.getChangesSubstring(currentText: "abccccc", previousText: "abc")
        
        XCTAssert((changes1.changes == "c") && (changes1.isInsertion == true))
        XCTAssert((changes2.changes == "a") && (changes2.isInsertion == true))
        XCTAssert((changes3.changes == "g") && (changes3.isInsertion == true))
        XCTAssert((changes4.changes == "ddddddde") && (changes4.isInsertion == true))
        XCTAssert((changes5.changes == "ddddddde") && (changes5.isInsertion == false))
        XCTAssert((changes6.changes == "aaaa") && (changes6.isInsertion == true))
        XCTAssert((changes7.changes == "lotsoftext") && (changes7.isInsertion == false))
        XCTAssert((changes8.changes == "cccc") && (changes8.isInsertion == true))
    }
}
