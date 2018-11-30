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
    func findPreviousUnit(for unit: NextLessonServiceUnitSourceProtocol) -> NextLessonServiceUnitSourceProtocol?
    func findNextUnit(for unit: NextLessonServiceUnitSourceProtocol) -> NextLessonServiceUnitSourceProtocol?
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

    func findPreviousUnit(for unit: NextLessonServiceUnitSourceProtocol) -> NextLessonServiceUnitSourceProtocol? {
        return self.findAdjacentUnit(for: unit, offset: .previous)
    }

    func findNextUnit(for unit: NextLessonServiceUnitSourceProtocol) -> NextLessonServiceUnitSourceProtocol? {
        return self.findAdjacentUnit(for: unit, offset: .next)
    }

    private func findAdjacentUnit(
        for unit: NextLessonServiceUnitSourceProtocol,
        offset: Offset
    ) -> NextLessonServiceUnitSourceProtocol? {
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

        // Unit has adjacent unit in section
        if unitIndex < section.units.count - 1 && offset == .next {
            return self.sections[sectionIndex].units[unitIndex + offset.rawValue]
        }

        if unitIndex > 0 && offset == .previous {
            return self.sections[sectionIndex].units[unitIndex + offset.rawValue]
        }

        // Find section
        var firstNonEmptySectionIndex = sectionIndex
        var firstNonEmptySection = self.sections[safe: sectionIndex]
        while firstNonEmptySection != nil {
            firstNonEmptySectionIndex += offset.rawValue
            firstNonEmptySection = self.sections[safe: firstNonEmptySectionIndex]

            guard let firstNonEmptySection = firstNonEmptySection else {
                break
            }

            if !firstNonEmptySection.units.isEmpty && firstNonEmptySection.isReachable {
                break
            }
        }

        // Target section
        guard let adjacentSection = firstNonEmptySection else {
            return nil
        }

        // Availability of target section
        guard !adjacentSection.units.isEmpty && adjacentSection.isReachable else {
            return nil
        }

        return offset == .next ? adjacentSection.units.first : adjacentSection.units.last
    }

    enum Offset: Int {
        case previous = -1
        case next = 1
    }
}
