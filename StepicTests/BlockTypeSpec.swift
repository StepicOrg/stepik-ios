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
                expect(Block.BlockType(rawValue: "text")) == Block.BlockType.text
            }

            it("is video") {
                expect(Block.BlockType(rawValue: "video")) == Block.BlockType.video
            }

            it("is animation") {
                expect(Block.BlockType(rawValue: "animation")) == Block.BlockType.animation
            }

            it("is chemical") {
                expect(Block.BlockType(rawValue: "chemical")) == Block.BlockType.chemical
            }

            it("is choice") {
                expect(Block.BlockType(rawValue: "choice")) == Block.BlockType.choice
            }

            it("is code") {
                expect(Block.BlockType(rawValue: "code")) == Block.BlockType.code
            }

            it("is dataset") {
                expect(Block.BlockType(rawValue: "dataset")) == Block.BlockType.dataset
            }

            it("is fill blanks") {
                expect(Block.BlockType(rawValue: "fill-blanks")) == Block.BlockType.fillBlanks
            }

            it("is free answer") {
                expect(Block.BlockType(rawValue: "free-answer")) == Block.BlockType.freeAnswer
            }

            it("is linux code") {
                expect(Block.BlockType(rawValue: "linux-code")) == Block.BlockType.linuxCode
            }

            it("is matching") {
                expect(Block.BlockType(rawValue: "matching")) == Block.BlockType.matching
            }

            it("is math") {
                expect(Block.BlockType(rawValue: "math")) == Block.BlockType.math
            }

            it("is number") {
                expect(Block.BlockType(rawValue: "number")) == Block.BlockType.number
            }

            it("is puzzle") {
                expect(Block.BlockType(rawValue: "puzzle")) == Block.BlockType.puzzle
            }

            it("is pycharm") {
                expect(Block.BlockType(rawValue: "pycharm")) == Block.BlockType.pycharm
            }

            it("is sorting") {
                expect(Block.BlockType(rawValue: "sorting")) == Block.BlockType.sorting
            }

            it("is sql") {
                expect(Block.BlockType(rawValue: "sql")) == Block.BlockType.sql
            }

            it("is string") {
                expect(Block.BlockType(rawValue: "string")) == Block.BlockType.string
            }

            it("is admin") {
                expect(Block.BlockType(rawValue: "admin")) == Block.BlockType.admin
            }
        }
    }
}
