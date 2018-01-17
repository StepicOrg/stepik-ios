//
//  CourseContentPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class CourseContentPresenter {

    weak var view: MenuCourseContentView?

    var course: Course? {
        didSet { loadSections() }
    }

    private var sections: [Section] = []

    private var sectionsViewData: [SectionViewData]? {
        didSet {
            guard let data = sectionsViewData else { return }
            view?.provide(sections: data)
        }
    }

    init(view: MenuCourseContentView) {
        self.view = view
    }

    func loadUnitsForSection(_ vc: DetailCourseContentView, index: Int) {
        guard let sectionsVD = sectionsViewData, sections.count > index else { fatalError() }
        let section = sections[index]

        section.loadUnits(success: {
            section.loadLessonsForUnits(units: section.units, completion: {
                sectionsVD[index].setData(lessons: section.units.map { $0.lesson! })
                vc.updateLessonsList()
            })
        }, error: {
            fatalError()
        })
    }

    private func loadSections() {
        guard let course = course else { return }

        course.loadAllSections(success: {
            self.sections = course.sections
            self.sectionsViewData = self.buildViewData(from: course.sections)
        }, error: { fatalError() })
    }

    private func buildViewData(from sections: [Section]) -> [SectionViewData] {
        guard let viewController = view as? UIViewController else { fatalError() }

        return sections.map { section in
            SectionViewData(title: section.title, progress: section.progress!)
        }
    }
}

class SectionViewData {
    let title: String
    let progress: Progress

    var lessons: [Lesson] = []

    init(title: String, progress: Progress) {
        self.title = title
        self.progress = progress
    }

    var progressText: String {
        return "\(progress.numberOfStepsPassed)/\(progress.numberOfSteps)"
    }

    var progressImage: UIImage {
        return #imageLiteral(resourceName: "placeholder")
    }

    func setData(lessons: [Lesson]) {
        self.lessons = lessons
    }
}
