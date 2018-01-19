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
        didSet {
            loadSections()

            guard let course = course, let viewController = view as? UIViewController else { return }

            let action: () -> Void = {
                let navigationController = ControllerHelper.instantiateViewController(identifier: "CourseInfoNavigation", storyboardName: "CourseInfo") as! UINavigationController

                let courseInfoVC = navigationController.viewControllers.first as! CourseInfoCollectionViewController

                courseInfoVC.presenter = CourseInfoPresenter(view: courseInfoVC)
                courseInfoVC.presenter?.course = course

                viewController.present(navigationController, animated: true, completion: {})
            }
            let courseInfo = CourseViewData(title: course.title, hosts: "", action: action)
            view?.provide(courseInfo: courseInfo)
        }
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
        guard let sectionsVD = sectionsViewData, let viewController = view as? UIViewController, sections.count > index else { fatalError() }
        let section = sections[index]

        section.loadUnits(success: {
            section.loadLessonsForUnits(units: section.units, completion: {
                sectionsVD[index].setData(lessons: section.units.map { $0.lesson! }, for: vc as? UIViewController)
                vc.updateLessonsList()
            })
        }, error: { print("error") })
    }

    private func loadSections() {
        guard let course = course else { return }

        course.loadAllSections(success: {
            [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.sections = course.sections
            strongSelf.sectionsViewData = strongSelf.buildViewData(from: course.sections)
        }, error: { print("error") })
    }

    private func buildViewData(from sections: [Section]) -> [SectionViewData] {
        return sections.map { section in
            SectionViewData(title: section.title, progress: section.progress!)
        }
    }
}

class SectionViewData {
    let title: String
    let progress: Progress

    var lessons: [LessonViewData] = []

    init(title: String, progress: Progress) {
        self.title = title
        self.progress = progress
    }

    var progressText: String {
        return "\(progress.score)/\(progress.cost)"
    }

    var progressImage: UIImage {
        return #imageLiteral(resourceName: "placeholder")
    }

    func setData(lessons: [Lesson], for viewController: UIViewController? ) {
        self.lessons = lessons.map { lesson in
            guard let progress = lesson.unit?.progress else { fatalError() }

            return LessonViewData(title: lesson.title, progress: progress) {
                let navigationController = ControllerHelper.instantiateViewController(identifier: "LessonContentNavigation", storyboardName: "LessonContent") as! UINavigationController

                let lessonContentVC = navigationController.viewControllers.first as! LessonStepsCollectionViewController

                lessonContentVC.navigationItem.title = lesson.title
                lessonContentVC.presenter = LessonContentPresenter(view: lessonContentVC)
                lessonContentVC.presenter?.lesson = lesson

                viewController?.present(navigationController, animated: true, completion: {})
            }
        }
    }
}

struct LessonViewData {
    let title: String
    let progress: Progress

    private(set) var action: (() -> Void)

    init(title: String, progress: Progress, action: @escaping () -> Void) {
        self.title = title
        self.progress = progress

        self.action = action
    }

    var progressText: String {
        return "\(progress.score)/\(progress.cost)"
    }

    var progressImage: UIImage {
        return #imageLiteral(resourceName: "placeholder")
    }

}

struct CourseViewData {
    let title: String
    let hosts: String

    private(set) var action: (() -> Void)

    init(title: String, hosts: String, action: @escaping () -> Void) {
        self.title = title
        self.hosts = hosts

        self.action = action
    }
}
