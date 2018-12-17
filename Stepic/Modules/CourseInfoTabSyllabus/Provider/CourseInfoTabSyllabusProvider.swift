//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusProvider.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabSyllabusProviderProtocol {
    func fetchSections(for course: Course, shouldUseNetwork: Bool) -> Promise<[Section]>
}

final class CourseInfoTabSyllabusProvider: CourseInfoTabSyllabusProviderProtocol {
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol

    init(
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol
    ) {
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
    }

    func fetchSections(for course: Course, shouldUseNetwork: Bool) -> Promise<[Section]> {
        return Promise { _ in
            firstly {
                shouldUseNetwork
                    ? self.sectionsNetworkService.fetch(ids: course.sectionsArray)
                    : self.sectionsPersistenceService.fetch(ids: course.sectionsArray)
            }.done { _ in

            }
        }
    }
}
