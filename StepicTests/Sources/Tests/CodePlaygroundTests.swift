@testable
import Stepic

import Nimble
import Quick

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
                    expect(result.isInsertion) == true
                }

                it("detects insertion in middle") {
                    let result = manager.getChangesSubstring(currentText: "abcde", previousText: "abde")
                    expect(result.changes) == "c"
                    expect(result.isInsertion) == true
                }

                it("detects insertion at end") {
                    let result = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcdef")
                    expect(result.changes) == "g"
                    expect(result.isInsertion) == true
                }

                describe("after the same character") {
                    context("at start") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "aaaaabc",
                                previousText: "abc"
                            )
                            expect(result.changes) == "aaaa"
                            expect(result.isInsertion) == true
                        }
                    }

                    context("in middle") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "abcddddddddeefg",
                                previousText: "abcdefg"
                            )
                            expect(result.changes) == "ddddddde"
                            expect(result.isInsertion) == true
                        }
                    }

                    context("at end") {
                        it("detects") {
                            let result = manager.getChangesSubstring(
                                currentText: "abccccc",
                                previousText: "abc"
                            )
                            expect(result.changes) == "cccc"
                            expect(result.isInsertion) == true
                        }
                    }
                }
            }

            describe("deletion") {
                it("detects deletion at start") {
                    let result = manager.getChangesSubstring(currentText: "bcdefg", previousText: "abcdefg")
                    expect(result.changes) == "a"
                    expect(result.isInsertion) == false
                }

                it("detects deletion in middle") {
                    let result = manager.getChangesSubstring(currentText: "abcdefg", previousText: "abcddddddddeefg")
                    expect(result.changes) == "ddddddde"
                    expect(result.isInsertion) == false
                }

                it("detects deletion at end") {
                    let result = manager.getChangesSubstring(currentText: "abc", previousText: "abcd")
                    expect(result.changes) == "d"
                    expect(result.isInsertion) == false
                }

                it("detects deletion of all text") {
                    let result = manager.getChangesSubstring(currentText: "", previousText: "abcd")
                    expect(result.changes) == "abcd"
                    expect(result.isInsertion) == false
                }
            }
        }

        describe("get current token") {
            let text = "def main()"

            var manager: CodePlaygroundManager!

            beforeEach {
                manager = CodePlaygroundManager()
            }

            it("returns valid token when cursor at start") {
                expect(manager.getCurrentToken(text: text, cursorPosition: 0)) == "def"
            }

            it("returns valid token when cursor at end") {
                expect(manager.getCurrentToken(text: "def main", cursorPosition: 8)) == "main"
                expect(manager.getCurrentToken(text: text, cursorPosition: 10)) == ""
            }

            it("returns valid token when cursor after word") {
                expect(manager.getCurrentToken(text: text, cursorPosition: 3)) == "def"
            }

            it("returns valid token when cursor before word") {
                expect(manager.getCurrentToken(text: text, cursorPosition: 4)) == "main"
            }

            it("returns valid token when cursor between word") {
                expect(manager.getCurrentToken(text: text, cursorPosition: 2)) == "def"
            }

            it("returns valid token when cursor between not allowed characters") {
                expect(manager.getCurrentToken(text: text, cursorPosition: 9)) == ""
            }

            it("returns valid token when cursor is out of bounds") {
                expect(manager.getCurrentToken(text: text, cursorPosition: -1)) == ""
                expect(manager.getCurrentToken(text: text, cursorPosition: 100)) == ""
            }

            it("returns valid token when text is empty") {
                expect(manager.getCurrentToken(text: "", cursorPosition: 0)) == ""
            }
        }

        describe("should make a new line after tab") {
            var manager: CodePlaygroundManager!

            beforeEach {
                manager = CodePlaygroundManager()
            }

            context("python") {
                it("should make not paired a new line after colon symbol") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: ":", language: .python) == expectedTuple) == true
                }

                it("should not make a new line after none colon symbol") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .python) == expectedTuple) == true
                }
            }

            context("c") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .c) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .c) == expectedTuple) == true
                }
            }

            context("C#") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .cs) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .cs) == expectedTuple) == true
                }
            }

            context("cpp") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .cpp) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .cpp11) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .cpp) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .cpp11) == expectedTuple) == true
                }
            }

            context("java") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .java) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .java8) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .java9) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .java11) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .java) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .java8) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .java9) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .java11) == expectedTuple) == true
                }
            }

            context("kotlin") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .kotlin) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .kotlin) == expectedTuple) == true
                }
            }

            context("swift") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .swift) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .swift) == expectedTuple) == true
                }
            }

            context("rust") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .rust) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .rust) == expectedTuple) == true
                }
            }

            context("javascript") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .javascript
                    ) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .javascript
                    ) == expectedTuple) == true
                }
            }

            context("scala") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .scala) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .scala) == expectedTuple) == true
                }
            }

            context("go") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .go) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .go) == expectedTuple) == true
                }
            }

            context("perl") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .perl) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .perl) == expectedTuple) == true
                }
            }

            context("php") {
                it("should make paired new line after opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: true, paired: true)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .php) == expectedTuple) == true
                }

                it("should not make a new line after none opening curly brace") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "}", language: .php) == expectedTuple) == true
                }
            }

            context("asm") {
                it("should not make a new tab line ") {
                    let expectedTuple = (shouldMakeNewLine: false, paired: false)
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .asm32) == expectedTuple) == true
                    expect(manager.shouldMakeTabLineAfter(symbol: "{", language: .asm64) == expectedTuple) == true
                }
            }
        }
    }
}
