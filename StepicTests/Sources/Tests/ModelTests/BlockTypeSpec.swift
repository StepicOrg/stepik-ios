@testable
import Stepic

import Foundation
import Nimble
import Quick

class BlockTypeSpec: QuickSpec {
    override func spec() {
        let names = [
            "animation", "chemical", "choice", "code", "dataset", "fill-blanks", "free-answer", "linux-code",
            "matching", "math", "number", "puzzle", "pycharm", "sorting", "sql", "string", "text", "video", "admin"
        ]

        describe("its parses correctly") {
            it("parses") {
                names.forEach { blockName in
                    expect(BlockType(rawValue: blockName)).notTo(beNil())
                }
            }

            it("is text") {
                expect(BlockType(rawValue: "text")) == .text
            }

            it("is video") {
                expect(BlockType(rawValue: "video")) == .video
            }

            it("is animation") {
                expect(BlockType(rawValue: "animation")) == .animation
            }

            it("is chemical") {
                expect(BlockType(rawValue: "chemical")) == .chemical
            }

            it("is choice") {
                expect(BlockType(rawValue: "choice")) == .choice
            }

            it("is code") {
                expect(BlockType(rawValue: "code")) == .code
            }

            it("is dataset") {
                expect(BlockType(rawValue: "dataset")) == .dataset
            }

            it("is fill blanks") {
                expect(BlockType(rawValue: "fill-blanks")) == .fillBlanks
            }

            it("is free answer") {
                expect(BlockType(rawValue: "free-answer")) == .freeAnswer
            }

            it("is linux code") {
                expect(BlockType(rawValue: "linux-code")) == .linuxCode
            }

            it("is matching") {
                expect(BlockType(rawValue: "matching")) == .matching
            }

            it("is math") {
                expect(BlockType(rawValue: "math")) == .math
            }

            it("is number") {
                expect(BlockType(rawValue: "number")) == .number
            }

            it("is puzzle") {
                expect(BlockType(rawValue: "puzzle")) == .puzzle
            }

            it("is pycharm") {
                expect(BlockType(rawValue: "pycharm")) == .pycharm
            }

            it("is sorting") {
                expect(BlockType(rawValue: "sorting")) == .sorting
            }

            it("is sql") {
                expect(BlockType(rawValue: "sql")) == .sql
            }

            it("is string") {
                expect(BlockType(rawValue: "string")) == .string
            }

            it("is admin") {
                expect(BlockType(rawValue: "admin")) == .admin
            }
        }
    }
}
