//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation

enum CourseInfoTabSyllabus {
    // MARK: Common structs

    struct SyllabusData {
        struct Record<T>: UniqueIdentifiable {
            let uniqueIdentifier: UniqueIdentifierType
            let entity: T
            let downloadState: DownloadState
        }

        let sections: [Record<Section>]
        let units: [Record<Unit?>]
        let sectionsDeadlines: [SectionDeadline]
        let isEnrolled: Bool
    }

    enum DownloadState {
        case notAvailable
        case waiting
        case available(isCached: Bool)
        case downloading(progress: Float)
    }

    // MARK: Use cases

    /// Course syllabus
    enum ShowSyllabus {
        struct Request { }

        struct Response {
            var result: Result<SyllabusData>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Load syllabus section
    enum ShowSyllabusSection {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Click on download button
    enum DownloadButtonAction {
        enum `Type` {
            case section(uniqueIdentifier: UniqueIdentifierType)
            case unit(uniqueIdentifier: UniqueIdentifierType)
            case all
        }

        struct Request {
            let type: Type
        }
    }

    /// Update download state
    enum DownloadButtonStateUpdate {
        enum Source {
            case unit(entity: Unit)
            case section(entity: Section)
        }

        enum Result {
            case section(viewModel: CourseInfoTabSyllabusSectionViewModel)
            case unit(viewModel: CourseInfoTabSyllabusUnitViewModel)
        }

        struct Response {
            let source: Source
            let downloadState: DownloadState
        }

        struct ViewModel {
            let data: Result
        }
    }

    /// Click on unit
    enum UnitSelect {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Update syllabus header (deadlines, download all)
    enum UpdateSyllabusHeader {
        struct Response {
            let isPersonalDeadlinesAvailable: Bool
            let isDownloadAllAvailable: Bool
        }

        struct ViewModel {
            let data: CourseInfoTabSyllabusHeaderViewModel
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CourseInfoTabSyllabusSectionViewModel])
    }
}
