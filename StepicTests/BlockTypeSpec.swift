@testable import Stepic
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
                    expect(Block.BlockType(rawValue: blockName)).notTo(beNil())
                }
            }

            it("is text") {
                expect(Block.BlockType(rawValue: "text")) == .text
            }

            it("is video") {
                expect(Block.BlockType(rawValue: "video")) == .video
            }

            it("is animation") {
                expect(Block.BlockType(rawValue: "animation")) == .animation
            }

            it("is chemical") {
                expect(Block.BlockType(rawValue: "chemical")) == .chemical
            }

            it("is choice") {
                expect(Block.BlockType(rawValue: "choice")) == .choice
            }

            it("is code") {
                expect(Block.BlockType(rawValue: "code")) == .code
            }

            it("is dataset") {
                expect(Block.BlockType(rawValue: "dataset")) == .dataset
            }

            it("is fill blanks") {
                expect(Block.BlockType(rawValue: "fill-blanks")) == .fillBlanks
            }

            it("is free answer") {
                expect(Block.BlockType(rawValue: "free-answer")) == .freeAnswer
            }

            it("is linux code") {
                expect(Block.BlockType(rawValue: "linux-code")) == .linuxCode
            }

            it("is matching") {
                expect(Block.BlockType(rawValue: "matching")) == .matching
            }

            it("is math") {
                expect(Block.BlockType(rawValue: "math")) == .math
            }

            it("is number") {
                expect(Block.BlockType(rawValue: "number")) == .number
            }

            it("is puzzle") {
                expect(Block.BlockType(rawValue: "puzzle")) == .puzzle
            }

            it("is pycharm") {
                expect(Block.BlockType(rawValue: "pycharm")) == .pycharm
            }

            it("is sorting") {
                expect(Block.BlockType(rawValue: "sorting")) == .sorting
            }

            it("is sql") {
                expect(Block.BlockType(rawValue: "sql")) == .sql
            }

            it("is string") {
                expect(Block.BlockType(rawValue: "string")) == .string
            }

            it("is admin") {
                expect(Block.BlockType(rawValue: "admin")) == .admin
            }
        }
    }
}
