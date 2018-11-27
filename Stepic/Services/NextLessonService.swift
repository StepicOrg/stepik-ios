//
//  NextLessonService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.11.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/// Service for determining next & previous lessons for given lesson in given course
protocol NextLessonServiceProtocol {
    func isPreviousUnitAvailable(for unit: NextLessonServiceUnitSourceProtocol) -> Bool
    func isNextUnitAvailable(for unit: NextLessonServiceUnitSourceProtocol) -> Bool
}

protocol NextLessonServiceSectionSourceProtocol: UniqueIdentifiable {
    /// Check if section can be reached
    var isReachable: Bool { get }
    /// List of units
    var units: [NextLessonServiceUnitSourceProtocol] { get }
}

protocol NextLessonServiceUnitSourceProtocol: UniqueIdentifiable { }

final class NextLessonService: NextLessonServiceProtocol {
    private let sections: [NextLessonServiceSectionSourceProtocol]

    init(contents: [NextLessonServiceSectionSourceProtocol]) {
        self.sections = contents
    }

    func isNextUnitAvailable(for unit: NextLessonServiceUnitSourceProtocol) -> Bool {
        return self.isAdjacentUnitAvailable(for: unit, offset: .next)
    }

    func isPreviousUnitAvailable(for unit: NextLessonServiceUnitSourceProtocol) -> Bool {
        return self.isAdjacentUnitAvailable(for: unit, offset: .previous)
    }

    private func isAdjacentUnitAvailable(
        for unit: NextLessonServiceUnitSourceProtocol,
        offset: Offset
    ) -> Bool {
        // offset == -1 => previous unit
        // offset == 1 => next unit
        guard abs(offset.rawValue) == 1 else {
            fatalError("Invalid offset parameter")
        }

        // Determine section for unit
        let sectionIndex: Int = {
            for (index, section) in self.sections.enumerated() {
                if section.units.contains(where: { $0.uniqueIdentifier == unit.uniqueIdentifier }) {
                    return index
                }
            }
            fatalError("Given unit doesn't belong to current sections list")
        }()

        let unitIndex: Int = {
            guard let index = self.sections[safe: sectionIndex]?.units.firstIndex(
                where: { $0.uniqueIdentifier == unit.uniqueIdentifier }
            ) else {
                fatalError("Section doesn't contain unit")
            }

            return index
        }()

        guard let section = self.sections[safe: sectionIndex] else {
            fatalError("Section not found")
        }

        let isUnitLastInSection = unitIndex == section.units.count - 1
        let isUnitFirstInSection = unitIndex == 0

        // Looking for next section
        var firstNonEmptySectionIndex = sectionIndex + offset.rawValue
        var firstNonEmptySection = self.sections[safe: firstNonEmptySectionIndex]
        while firstNonEmptySection != nil && firstNonEmptySection?.units.isEmpty ?? false {
            firstNonEmptySection = self.sections[safe: sectionIndex + offset.rawValue]
            firstNonEmptySectionIndex += offset.rawValue
        }

        let isAdjacentSectionEmpty = firstNonEmptySection?.units.isEmpty ?? true
        let isAdjacentSectionReachable = firstNonEmptySection?.isReachable ?? false

        switch offset {
        case .next:
            return (!isAdjacentSectionEmpty && !isAdjacentSectionReachable) || !isUnitLastInSection
        case .previous:
            return (!isAdjacentSectionEmpty && !isAdjacentSectionReachable) || !isUnitFirstInSection
        }
    }

    enum Offset: Int {
        case previous = -1
        case next = 1
    }
}
