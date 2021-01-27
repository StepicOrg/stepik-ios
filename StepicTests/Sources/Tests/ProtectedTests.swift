@testable
import Stepic

import XCTest

final class ProtectedTests: XCTestCase {
    func testThatProtectedValuesAreAccessedSafely() {
        // Given
        let initialValue = "value"
        let protected = Protected<String>(initialValue)

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { i in
            _ = protected.wrappedValue
            protected.wrappedValue = "\(i)"
        }

        // Then
        XCTAssertNotEqual(protected.wrappedValue, initialValue)
    }

    func testThatProtectedAPIIsSafe() {
        // Given
        let initialValue = "value"
        let protected = Protected<String>(initialValue)

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { i in
            _ = protected.read { $0 }
            protected.write { $0 = "\(i)" }
        }

        // Then
        XCTAssertNotEqual(protected.wrappedValue, initialValue)
    }
}

final class ProtectedWrapperTests: XCTestCase {
    @Protected var value = "value"

    override func setUp() {
        super.setUp()

        value = "value"
    }

    func testThatWrappedValuesAreAccessedSafely() {
        // Given
        let initialValue = value

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { i in
            _ = value
            value = "\(i)"
        }

        // Then
        XCTAssertNotEqual(value, initialValue)
    }

    func testThatProjectedAPIIsAccessedSafely() {
        // Given
        let initialValue = value

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { i in
            _ = $value.read { $0 }
            $value.write { $0 = "\(i)" }
        }

        // Then
        XCTAssertNotEqual(value, initialValue)
    }

    func testThatDynamicMembersAreAccessedSafely() {
        // Given
        let count = Protected<Int>(0)

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
            count.wrappedValue = value.count
        }

        // Then
        XCTAssertEqual(count.wrappedValue, 5)
    }

    func testThatDynamicMembersAreSetSafely() {
        // Given
        struct Mutable { var value = "value" }
        let mutable = Protected<Mutable>(.init())

        // When
        DispatchQueue.concurrentPerform(iterations: 10_000) { i in
            mutable.value = "\(i)"
        }

        // Then
        XCTAssertNotEqual(mutable.wrappedValue.value, "value")
    }
}
