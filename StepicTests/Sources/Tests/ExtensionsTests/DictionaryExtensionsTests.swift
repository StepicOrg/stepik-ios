@testable
import Stepic

import XCTest

final class DictionaryExtensionsTests: XCTestCase {
    func testMapKeysAndValues() {
        let intToString = [0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9"]

        let stringToInt: [String: Int] = intToString.mapKeysAndValues { key, value in
            return (String(describing: key), Int(value)!)
        }

        XCTAssertEqual(stringToInt, ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9])
    }

    func testCompactMapKeysAndValues() {
        enum IntWord: String {
            case zero
            case one
            case two
        }

        let strings = [
            0: "zero",
            1: "one",
            2: "two",
            3: "three"
        ]
        let words: [String: IntWord] = strings.compactMapKeysAndValues { key, value in
            guard let word = IntWord(rawValue: value) else {
                return nil
            }
            return (String(describing: key), word)
        }

        XCTAssertEqual(words, ["0": .zero, "1": .one, "2": .two])
    }
}
