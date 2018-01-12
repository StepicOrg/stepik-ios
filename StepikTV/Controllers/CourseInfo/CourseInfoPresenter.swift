//
//  CourseInfoPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class CourseInfoPresenter {

    private weak var view: CourseInfoView?

    var course: Course? {
        didSet {
            guard let course = course else { return }
            course.loadAllInstructors {
                self.instructors = course.instructors
                self.view?.provide(sections: self.buildSections(with: course))
            }
        }
    }
    var instructors: [User]?
    var sections: [CourseInfoSection] = []

    init(view: CourseInfoView) {
        self.view = view
    }

    private func buildSections(with course: Course) -> [CourseInfoSection] {
        guard let viewController = view as? UIViewController else { fatalError() }

        let title = course.title
        let hosts = ""
        let descr = course.courseDescription
        let imageURL = URL(string: course.coverURLString)
        let trailerAction: (Video) -> Void = {_ in }
        let subscriptionAction: (Course) -> Void = {_ in }

        let selectionAction: (TVFocusableText) -> Void = {
            let textPresenter = TVTextPresentationAlertController(title: "", message: "", preferredStyle: .alert)
            textPresenter.setText($0.text ?? "")
            viewController.present(textPresenter, animated: true, completion: {})
        }

        let mainSection = CourseInfoSection(.main(hosts: [hosts], descr: descr, imageURL: imageURL, trailerAction: trailerAction, subscriptionAction: subscriptionAction, selectionAction: selectionAction), title: title)

        let summary = course.summary
        let summarySection = CourseInfoSection(.text(content: summary, selectionAction: selectionAction), title: "Summary")

        guard let instructors = instructors else { return [mainSection, summarySection] }

        let instructorsViewData = instructors.map { instructor in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: instructor.avatarURL, title: "\(instructor.lastName) \(instructor.firstName)") { }
        }
        let instructorsSection = CourseInfoSection(.instructors(items: instructorsViewData), title: "Instructors")

        return [mainSection, instructorsSection, summarySection]
    }
}

struct CourseInfoSection {
    let title: String
    let contentType: CourseInfoSectionType

    init(_ contentType: CourseInfoSectionType, title: String) {
        self.contentType = contentType
        self.title = title
    }
}

enum CourseInfoSectionType {
    case main(hosts: [String], descr: String, imageURL: URL?, trailerAction: (Video) -> Void, subscriptionAction: (Course) -> Void, selectionAction: (TVFocusableText) -> Void)
    case text(content: String, selectionAction: (TVFocusableText) -> Void)
    case instructors(items: [ItemViewData])

    var viewClass: CourseInfoSectionViewProtocol.Type {
        switch self {
        case .main:
            return MainCourseInfoSectionCell.self
        case .text:
            return DetailsCourseInfoSectionCell.self
        case .instructors:
            return InstructorsCourseInfoSectionCell.self
        }
    }
}
