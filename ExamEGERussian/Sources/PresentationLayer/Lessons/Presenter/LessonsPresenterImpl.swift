//
//  LessonsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class LessonsPresenterImpl: LessonsPresenter {

    private weak var view: LessonsView?
    private let topicId: String
    private let knowledgeGraph: KnowledgeGraph
    private var lessons = [LessonPlainObject]()
    private let lessonsService: LessonsService

    private var lessonsIds: [Int] {
        guard let topic = knowledgeGraph[topicId]?.key else { return [] }
        return topic.lessons.filter { $0.type == .theory }.map { $0.id }
    }

    init(view: LessonsView, topicId: String, knowledgeGraph: KnowledgeGraph,
         lessonsService: LessonsService) {
        self.view = view
        self.topicId = topicId
        self.knowledgeGraph = knowledgeGraph
        self.lessonsService = lessonsService
    }

    func refresh() {
        fetchLessons()
    }

    // MARK: - Private API

    private func fetchLessons() {
        guard lessonsIds.count > 0 else { return }
        lessonsService.obtainLessons(with: lessonsIds).done { [weak self] responseModel in
            guard let `self` = self else { return }
            self.lessons = responseModel
            let viewData = self.viewLessons(from: self.lessons)
            self.view?.setLessons(viewData)
        }.catch { [weak self] error in
            self?.displayError(error)
        }
    }

    private func viewLessons(from lessons: [LessonPlainObject]) -> [LessonsViewData] {
        return lessons.map { LessonsViewData(id: $0.id, title: $0.title) }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
    }
}
