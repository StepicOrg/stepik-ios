import Nimble
import Quick

@testable import Stepic

class CodePlaygroundSpec: QuickSpec {
    override func spec() {
        describe("substring changes") {
            var manager: CodePlaygroundManager!

            beforeEach {
                manager = CodePlaygroundManager()
            }

            describe("insertion") {
                it("detects insertion at start") {
                    let result = manager.getChangesSubstring(currentText: "abcdefg", previousText: "bcdefg")
                    expect(result.changes) == "a"
                    expect(result.isInsertion).to(beTrue())
                }

                it("detects insertion in middle") {
                    let result = manager.getChangesSubstring(currentText: "abcde", previousText: "abde")
                    expect(result.changes) == "c"
                    expect(result.isInsertion).to(beTrue())
                }

                it("detects insertion at end") {
                    let result = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcdef")
                    expect(result.changes) == "g"
                    expect(result.isInsertion).to(beTrue())
                }

                describe("after the same character") {
                    context("at start") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "aaaaabc",
                                previousText: "abc"
                            )
                            expect(result.changes) == "aaaa"
                            expect(result.isInsertion).to(beTrue())
                        }
                    }

                    context("in middle") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "abcddddddddeefg",
                                previousText: "abcdefg"
                            )
                            expect(result.changes) == "ddddddde"
                            expect(result.isInsertion).to(beTrue())
                        }
                    }

                    context("at end") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "abccccc",
                                previousText: "abc"
                            )
                            expect(result.changes) == "cccc"
                            expect(result.isInsertion).to(beTrue())
                        }
                    }
                }
            }

            describe("deletion") {
                it("detects deletion at start") {
                    let result = manager.getChangesSubstring(currentText: "bcdefg", previousText: "abcdefg")
                    expect(result.changes) == "a"
                    expect(result.isInsertion).to(beFalse())
                }

                it("detects deletion in middle") {
                    let result = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcddddddddeefg")
                    expect(result.changes) == "ddddddde"
                    expect(result.isInsertion).to(beFalse())
                }

                it("detects deletion at end") {
                    let result = manager.getChangesSubstring(currentText: "abc", previousText: "abcd")
                    expect(result.changes) == "d"
                    expect(result.isInsertion).to(beFalse())
                }

                it("detects deletion of all text") {
                    let result = manager.getChangesSubstring(currentText: "", previousText: "abcd")
                    expect(result.changes) == "abcd"
                    expect(result.isInsertion).to(beFalse())
                }
            }
        }
    }
}
