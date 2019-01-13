//
//  PersonalDeadlinesTimeService.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol PersonalDeadlinesTimeServiceProtocol: class {
    func countDeadlines(mode: DeadlineMode, for course: Course) -> Promise<[SectionDeadline]>
}

final class PersonalDeadlinesTimeService: PersonalDeadlinesTimeServiceProtocol {
    enum DeadlineCountError: Error {
        case noSectionInfo, unitsLoadError
    }

    let sectionTimeMultiplier = 1.3

    func countDeadlines(mode: DeadlineMode, for course: Course) -> Promise<[SectionDeadline]> {
        return Promise { seal in
            var sectionCounters: [Promise<(Int, TimeInterval)>] = []
            for section in course.sections {
                sectionCounters += [countTimeToComplete(section: section)]
            }
            when(fulfilled: sectionCounters).done { [weak self] timeTuples in
                guard let strongSelf = self else {
                    seal.reject(UnwrappingError.optionalError)
                    return
                }
                var timeForSection: [Int: TimeInterval] = [:]
                for timeTuple in timeTuples {
                    timeForSection[timeTuple.0] = timeTuple.1 * strongSelf.sectionTimeMultiplier
                }
                var sectionDeadlines: [SectionDeadline] = []
                var previousDeadline: Date = Date()
                for sectionId in course.sectionsArray {
                    guard let secondsToCompleteSection = timeForSection[sectionId] else {
                        seal.reject(DeadlineCountError.noSectionInfo)
                        return
                    }
                    let daysToCompleteSection = Int(ceil(secondsToCompleteSection / Double(mode.getModeInfo().dailyLoadSeconds)))

                    sectionDeadlines += [SectionDeadline(section: sectionId, deadlineDate: strongSelf.getDeadlineDateForSection(since: previousDeadline, daysToComplete: daysToCompleteSection))]
                    previousDeadline = sectionDeadlines.last?.deadlineDate ?? Date()
                }
                seal.fulfill(sectionDeadlines)
            }.catch { error in
                print("\(#file) \(#function) \(error)")
            }
        }
    }

    private func getDeadlineDateForSection(since startDate: Date, daysToComplete: Int) -> Date {
        let secondsInDay: Double = 60 * 60 * 24
        let endDate = startDate.addingTimeInterval(TimeInterval(Double(daysToComplete) * secondsInDay))
        return Calendar.current.startOfDay(for: endDate).addingTimeInterval(secondsInDay - 60)
    }

    private func countTimeToComplete(section: Section) -> Promise<(Int, TimeInterval)> {
        return Promise { seal in
            section.loadUnits(success: {
                var sectionTimeToComplete: Double = 0
                for unit in section.units {
                    sectionTimeToComplete += unit.lesson?.timeToComplete ?? 0
                }
                seal.fulfill((section.id, sectionTimeToComplete))
            }, error: {
                seal.reject(DeadlineCountError.unitsLoadError)
            })
        }
    }
}
