//
//  ViewsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 23/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class ViewsService: ViewsServiceProtocol {
    private let unitsAPI: UnitsAPI
    private let viewsAPI: ViewsAPI

    init(unitsAPI: UnitsAPI, viewsAPI: ViewsAPI) {
        self.unitsAPI = unitsAPI
        self.viewsAPI = viewsAPI
    }

    func sendView(for step: StepPlainObject) -> Promise<Void> {
        return Promise { seal in
            guard let lesson = Lesson.getLesson(step.lessonId) else {
                throw ViewsServiceError.viewNotSent
            }

            self.unitsAPI.retrieve(lesson: lesson.id).then { unit -> Promise<Void> in
                guard let assignmentId = unit.assignmentsArray.first else {
                    seal.reject(ViewsServiceError.viewNotSent)
                    return .value(())
                }

                return self.viewsAPI.create(step: step.id, assignment: assignmentId)
            }.done { _ in
                seal.fulfill(())
            }.catch { _ in
                seal.reject(ViewsServiceError.viewNotSent)
            }
        }
    }

    enum ViewsServiceError: Error {
        case viewNotSent
    }
}
