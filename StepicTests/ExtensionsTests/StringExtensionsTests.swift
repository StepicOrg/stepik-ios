import Nimble
import Quick

@testable import Stepic

final class StringExtensionsSpec: QuickSpec {
    override func spec() {
        describe("safe subscript") {
            let string = "Hello world!"

            describe("with index") {
                it("returns correct `Character`") {
                    expect(string[safe: 0]) == "H"
                    expect(string[safe: 1]) == "e"
                    expect(string[safe: 11]) == "!"
                }

                it("returns `nil`") {
                    expect(string[safe: -1]).to(beNil())
                    expect(string[safe: 12]).to(beNil())
                    expect(string[safe: 18]).to(beNil())
                    expect(""[safe: 0]).to(beNil())
                }
            }

            describe("within a half-open range") {
                it("returns correct `String`") {
                    expect(string[safe: 1..<1]) == ""
                    expect(string[safe: 1..<2]) == "e"
                    expect(string[safe: 1..<5]) == "ello"
                    expect(string[safe: 0..<12]) == "Hello world!"
                }

                it("returns `nil`") {
                    expect(string[safe: 10..<18]).to(beNil())
                    expect(""[safe: 1..<2]).to(beNil())
                }
            }

            describe("within a closed range") {
                it("returns correct `String`") {
                    expect(string[safe: 0...0]) == "H"
                    expect(string[safe: 0...4]) == "Hello"
                }

                it("returns `nil`") {
                    expect(string[safe: 10...18]).to(beNil())
                    expect(""[safe: 1...2]).to(beNil())
                }
            }
        }
    }
}
