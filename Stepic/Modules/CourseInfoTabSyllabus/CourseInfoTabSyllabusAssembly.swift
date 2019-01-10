//
//  CourseInfoTabSyllabusAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import UIKit

final class CourseInfoTabSyllabusAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabSyllabusInputProtocol?

    // Output
    private weak var moduleOutput: CourseInfoTabSyllabusOutputProtocol?

    init(output: CourseInfoTabSyllabusOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabSyllabusProvider(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            lessonsPersistenceService: LessonsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI())
        )
        let presenter = CourseInfoTabSyllabusPresenter()
        let interactor = CourseInfoTabSyllabusInteractor(
            presenter: presenter,
            provider: provider,
            videoFileManager: VideoStoredFileManager(fileManager: FileManager.default),
            syllabusDownloadsInteractionService: SyllabusDownloadsInteractionService(
                videoDownloadingService: VideoDownloadingService.shared
            )
        )
        let viewController = CourseInfoTabSyllabusViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
