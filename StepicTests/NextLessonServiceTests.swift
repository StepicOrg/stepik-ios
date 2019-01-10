//
//  NextLessonServiceTests.swift
//  StepicTests
//
//  Created by jetbrains on 28/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest
import Mockingjay

@testable import Stepic

/// Singleton to provide unique identifiers factory
final class UniqueIDsPool {
    static let shared = UniqueIDsPool()

    private var counter: Int = 0

    var id: UniqueIdentifierType {
        self.counter += 1
        return "\(self.counter)"
    }
}

final class SectionMock: NextLessonServiceSectionSourceProtocol {
    var uniqueIdentifier: UniqueIdentifierType

    let isReachable: Bool
    let units: [NextLessonServiceUnitSourceProtocol]

    init(unitsCount: Int, isReachable: Bool) {
        self.isReachable = isReachable
        self.units = (0..<unitsCount).map { _ in UnitMock() }
        self.uniqueIdentifier = UniqueIDsPool.shared.id
    }
}

final class UnitMock: NextLessonServiceUnitSourceProtocol {
    var uniqueIdentifier: UniqueIdentifierType

    init() {
        self.uniqueIdentifier = UniqueIDsPool.shared.id
    }
}

final class NextLessonServiceSpec: QuickSpec {
    override func spec() {
        describe("NextLessonService") {
            // Common
            context("when created with non-empty reachable sections") {
                let sections: [NextLessonServiceSectionSourceProtocol] = [
                    SectionMock(unitsCount: 5, isReachable: true),
                    SectionMock(unitsCount: 5, isReachable: true),
                    SectionMock(unitsCount: 5, isReachable: true)
                ]
                let service: NextLessonServiceProtocol = NextLessonService(sections: sections)

                it("returns correct next and previous units for unit in the middle of section") {
                    let sourceUnit = sections.first!.units[2]
                    let nextUnit = sections.first!.units[3]
                    let prevUnit = sections.first!.units[1]
                    expect(service.findNextUnit(for: sourceUnit)) === nextUnit
                    expect(service.findPreviousUnit(for: sourceUnit)) === prevUnit
                }

                it("returns nil for first unit in first section and for last unit in last section") {
                    let firstUnit = sections.first!.units.first!
                    let lastUnit = sections.last!.units.last!
                    expect(service.findPreviousUnit(for: firstUnit)).to(beNil())
                    expect(service.findNextUnit(for: lastUnit)).to(beNil())
                }
            }

            // APPS-1666
            context("when created with empty and unreachable sections between two non-empty sections") {
                let sections: [NextLessonServiceSectionSourceProtocol] = [
                    SectionMock(unitsCount: 5, isReachable: true),
                    SectionMock(unitsCount: 0, isReachable: true),
                    SectionMock(unitsCount: 0, isReachable: true),
                    SectionMock(unitsCount: 5, isReachable: true)
                ]
                let service: NextLessonServiceProtocol = NextLessonService(sections: sections)

                it("returns correct next unit for last unit of first section") {
                    let sourceUnit = sections.first!.units.last!
                    let targetUnit = sections.last!.units.first!
                    expect(service.findNextUnit(for: sourceUnit)) === targetUnit
                }

                it("returns correct prev unit for first unit of last section") {
                    let sourceUnit = sections.last!.units.first!
                    let targetUnit = sections.first!.units.last!
                    expect(service.findPreviousUnit(for: sourceUnit)) === targetUnit
                }
            }

            // APPS-1647
            context("when created with non-empty section among empty section") {
                let sections: [NextLessonServiceSectionSourceProtocol] = [
                    SectionMock(unitsCount: 0, isReachable: true),
                    SectionMock(unitsCount: 5, isReachable: true),
                    SectionMock(unitsCount: 0, isReachable: true)
                ]
                let service: NextLessonServiceProtocol = NextLessonService(sections: sections)

                it("returns nil next unit for last unit in non-empty section") {
                    let sourceUnit = sections[1].units.last!
                    expect(service.findNextUnit(for: sourceUnit)).to(beNil())
                }

                it("returns nil prev unit for first unit in non-empty section") {
                    let sourceUnit = sections[1].units.first!
                    expect(service.findPreviousUnit(for: sourceUnit)).to(beNil())
                }
            }

            // APPS-1629
            context("when created with non-empty reachable section among unareachable sections") {
                let sections: [NextLessonServiceSectionSourceProtocol] = [
                    SectionMock(unitsCount: 0, isReachable: false),
                    SectionMock(unitsCount: 5, isReachable: true),
                    SectionMock(unitsCount: 0, isReachable: false)
                ]
                let service: NextLessonServiceProtocol = NextLessonService(sections: sections)

                it("returns nil next unit for last unit in reachable section") {
                    let sourceUnit = sections[1].units.last!
                    expect(service.findNextUnit(for: sourceUnit)).to(beNil())
                }

                it("returns nil prev unit for first unit in reachable section") {
                    let sourceUnit = sections[1].units.first!
                    expect(service.findPreviousUnit(for: sourceUnit)).to(beNil())
                }
            }
        }
    }
}
