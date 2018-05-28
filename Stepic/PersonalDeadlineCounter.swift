//
//  PersonalDeadlineCounter.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class PersonalDeadlineCounter {

    static let shared = PersonalDeadlineCounter()

    enum DeadlineCountError: Error {
        case noSectionInfo
    }

    let sectionTimeMultiplier = 1.3

    func countDeadlines(mode: DeadlineMode, for course: Course) -> Promise<[SectionDeadline]> {
        return Promise {
            fulfill, reject in
            var sectionCounters: [Promise<(Int, TimeInterval)>] = []
            for section in course.sections {
                sectionCounters += [countTimeToComplete(section: section)]
            }
            when(fulfilled: sectionCounters).then {
                [weak self]
                timeTuples -> Void in
                guard let strongSelf = self else {
                    reject(UnwrappingError.optionalError)
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
                        reject(DeadlineCountError.noSectionInfo)
                        return
                    }
                    let daysToCompleteSection = Int(ceil(secondsToCompleteSection / Double(mode.getModeInfo().dailyLoadSeconds)))

                    sectionDeadlines += [SectionDeadline(section: sectionId, deadlineDate: strongSelf.getDeadlineDateForSection(since: previousDeadline, daysToComplete: daysToCompleteSection))]
                    previousDeadline = sectionDeadlines.last?.deadlineDate ?? Date()
                }
                fulfill(sectionDeadlines)
            }
        }
    }

    private func getDeadlineDateForSection(since startDate: Date, daysToComplete: Int) -> Date {
        let endDate = startDate.addingTimeInterval(TimeInterval(daysToComplete * 60 * 60 * 24))
        return Calendar.current.startOfDay(for: endDate).addingTimeInterval(23 * 60 * 60 + 59 * 60)
    }

    private func countTimeToComplete(section: Section) -> Promise<(Int, TimeInterval)> {
        return Promise {
            fulfill, _ in
            section.loadUnits(success: {
                section.loadLessonsForUnits(units: section.units, completion: {
                    [weak self] in
                    var sectionTimeToComplete: Double = 0
                    for unit in section.units {
                        sectionTimeToComplete += unit.lesson?.timeToComplete ?? 0
                    }
                    print("time to complete section \(section.id) = \(sectionTimeToComplete)")
                    fulfill((section.id, sectionTimeToComplete))
                }, error: {
                    //TODO: Add error handling here
                })
            }, error: {
                //TODO: Add error handling here
            })
        }
    }
}
