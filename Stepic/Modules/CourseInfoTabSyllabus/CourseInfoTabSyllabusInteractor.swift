//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabSyllabusInteractorProtocol {
    func getCourseSyllabus()
    func fetchSyllabusSection(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request)
}

final class CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInteractorProtocol {
    let presenter: CourseInfoTabSyllabusPresenterProtocol
    let provider: CourseInfoTabSyllabusProviderProtocol

    private var currentCourse: Course?
    private var currentSections: [UniqueIdentifierType: Section] = [:]
    private var currentUnits: [UniqueIdentifierType: Unit?] = [:]

    private var isOnline = false {
        willSet {
            if !newValue && self.isOnline {
                fatalError("Online -> offline transition not supported")
            }
        }
    }
    private var didLoadFromNetwork = false {
        willSet {
            if !newValue && self.didLoadFromNetwork {
                fatalError("Online -> offline transition not supported")
            }
        }
    }

    // Fetch syllabus only after previous fetch completed
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    // Online mode: present section only previous presentation completed
    private let sectionPresentSemaphore = DispatchSemaphore(value: 1)
    // Online mode: fetch section only when offline fetching completed
    private let sectionFetchSemaphore = DispatchSemaphore(value: 0)

    private lazy var backgroundQueue = DispatchQueue(label: String(describing: self))

    init(
        presenter: CourseInfoTabSyllabusPresenterProtocol,
        provider: CourseInfoTabSyllabusProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func getCourseSyllabus() {
        guard let course = self.currentCourse else {
            return
        }

        self.backgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("course info tab syllabus interactor: start fetching syllabus, isOnline = \(isOnline)")

            strongSelf.fetchSyllabusInAppropriateMode(
                course: course,
                isOnline: isOnline
            ).done { response in
                DispatchQueue.main.async {
                    print("course info tab syllabus interactor: finish fetching syllabus, isOnline = \(isOnline)")
                    strongSelf.presenter.presentCourseSyllabus(response: response)

                    if isOnline && !strongSelf.didLoadFromNetwork {
                        strongSelf.didLoadFromNetwork = true
                        strongSelf.sectionFetchSemaphore.signal()
                    }
                }
            }.catch { _ in
                // TODO: handle
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func fetchSyllabusSection(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request) {
        self.backgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            guard let section = strongSelf.currentSections[request.uniqueIdentifier] else {
                return
            }

            // Check whether section fetching completed
            strongSelf.sectionFetchSemaphore.wait()
            strongSelf.sectionFetchSemaphore.signal()

            print("course info tab syllabus interactor: start fetching section from network, id = \(section.id)")
            strongSelf.fetchSyllabusSection(section: section).done { response in
                _ = strongSelf.sectionPresentSemaphore.wait(timeout: .now() + 0.5)
                DispatchQueue.main.async { [weak self] in
                    print("course info tab syllabus interactor: finish fetching section from network, id = \(section.id)")
                    self?.presenter.presentCourseSyllabus(response: response)
                    self?.sectionPresentSemaphore.signal()
                }
            }.catch { _ in
                // TODO: handle
            }
        }
    }

    private func fetchSyllabusSection(
        section: Section
    ) -> Promise<CourseInfoTabSyllabus.ShowSyllabus.Response> {
        return Promise { seal in
            self.provider.fetchUnitsWithLessons(
                for: section,
                shouldUseNetwork: true
            ).done { units in
                self.updateCurrentData(units: units, shouldRemoveAll: false)

                let data = CourseInfoTabSyllabus.SyllabusData(
                    sections: self.currentSections.map { ($0.key, $0.value) },
                    units: self.currentUnits.map { ($0.key, $0.value) }
                )
                seal.fulfill(.init(result: .success(data)))
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func fetchSyllabusInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabSyllabus.ShowSyllabus.Response> {
        return Promise { seal in
            // Load sections & progresses
            self.provider.fetchSections(for: course, shouldUseNetwork: isOnline).then {
                sections -> Promise<([Section], [[Unit]])> in
                // In offline mode load units & lessons just now
                // In online mode load units & lessons on demand

                let offlineUnitsPromise = when(
                    fulfilled: sections.map { section in
                        self.provider.fetchUnitsWithLessons(for: section, shouldUseNetwork: false)
                    }
                )
                let onlineUnitsPromise = Promise.value([[Unit]]())

                let unitsPromise = isOnline ? onlineUnitsPromise : offlineUnitsPromise
                return unitsPromise.map { (sections, $0) }
            }.done { result in
                let sections = result.0
                let units = Array(result.1.joined())

                self.updateCurrentData(sections: sections, units: units, shouldRemoveAll: true)

                let data = CourseInfoTabSyllabus.SyllabusData(
                    sections: self.currentSections.map { ($0.key, $0.value) },
                    units: self.currentUnits.map { ($0.key, $0.value) }
                )
                seal.fulfill(.init(result: .success(data)))
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func updateCurrentData(sections: [Section]? = nil, units: [Unit], shouldRemoveAll: Bool) {
        if shouldRemoveAll {
            self.currentSections.removeAll(keepingCapacity: true)
            self.currentUnits.removeAll(keepingCapacity: true)
        }

        for section in sections ?? [] {
            self.currentSections[self.getUniqueIdentifierBySectionID(section.id)] = section
            for unitID in section.unitsArray {
                self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] = nil
            }
        }

        for unit in units {
            self.currentUnits[self.getUniqueIdentifierByUnitID(unit.id)] = unit
        }
    }

    private func getUniqueIdentifierBySectionID(_ sectionID: Section.IdType) -> UniqueIdentifierType {
        return "\(sectionID)"
    }

    private func getUniqueIdentifierByUnitID(_ unitID: Unit.IdType) -> UniqueIdentifierType {
        return "\(unitID)"
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol {
    func update(with course: Course, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline
        self.getCourseSyllabus()
    }
}
