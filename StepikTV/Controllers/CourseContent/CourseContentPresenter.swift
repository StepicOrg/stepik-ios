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
                let courseInfoVC = ControllerHelper.instantiateViewController(identifier: "CourseInfoPage", storyboardName: "CourseInfo") as! CourseInfoCollectionViewController

                courseInfoVC.presenter = CourseInfoPresenter(view: courseInfoVC)
                courseInfoVC.presenter?.course = course

                viewController.present(courseInfoVC, animated: true, completion: {})
            }
            let courseInfo = CourseViewData(title: course.title, hosts: "", action: action)
            view?.provide(courseInfo: courseInfo)
        }
    }

    private var sections: [Section] = []
    private var sectionsViewData: [SectionViewData] = [] {
        didSet {
            view?.provide(sections: sectionsViewData)
        }
    }

    init(view: MenuCourseContentView) {
        self.view = view
    }

    func loadUnitsForSection(_ detailView: DetailCourseContentView, index: Int) {
        guard sectionsViewData[index].loadingStatus == .none else {
            detailView.showLoading(isVisible: (sectionsViewData[index].loadingStatus != .loaded))
            return
        }

        if index >= sections.count { fatalError() }

        detailView.showLoading(isVisible: true)
        sections[index].loadUnits(success: {
            [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.sectionsViewData[index].loadingStatus = .loading
            strongSelf.sections[index].loadLessonsForUnits(units: strongSelf.sections[index].units, completion: {

                strongSelf.sectionsViewData[index].setData(lessons: strongSelf.sections[index].units.map { $0.lesson! }, for: strongSelf.view as? UIViewController)

                detailView.showLoading(isVisible: false)
                detailView.update()
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

enum LoadingStatus {
    case none, loading, loaded
}

class SectionViewData {
    let title: String
    let progress: Progress

    var loadingStatus: LoadingStatus = .none

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
        loadingStatus = .loaded
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
        let deviation = Float(progress.score) / Float(progress.cost)

        guard deviation != 0.0, progress.cost != 0 else { return #imageLiteral(resourceName: "progress_icon@nil") }
        guard deviation > 1 / 8  else { return #imageLiteral(resourceName: "progress_icon@18") }
        guard deviation > 1 / 4 else { return #imageLiteral(resourceName: "progress_icon@14") }
        guard deviation > 3 / 8 else { return #imageLiteral(resourceName: "progress_icon@38") }
        guard deviation > 1 / 2 else { return #imageLiteral(resourceName: "progress_icon@12") }
        guard deviation > 5 / 8 else { return #imageLiteral(resourceName: "progress_icon@58") }
        guard deviation > 3 / 4 else { return #imageLiteral(resourceName: "progress_icon@34") }
        guard deviation > 7 / 8 else { return #imageLiteral(resourceName: "progress_icon@78") }

        return #imageLiteral(resourceName: "progress_icon@full")
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
