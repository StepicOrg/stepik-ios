//
//  CourseInfoPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseInfoPresenter {

    private weak var view: CourseInfoView?

    var course: Course? {
        didSet {
            guard let course = course else { return }
            view?.provide(sections: buildSections(with: course))
        }
    }
    var sections: [CourseInfoSection] = []

    init(view: CourseInfoView) {
        self.view = view
    }

    private func buildSections(with course: Course) -> [CourseInfoSection] {
        let title = course.title
        let hosts = ""
        let descr = course.courseDescription
        let imageURL = URL(string: course.coverURLString)
        let introVideo = course.introVideo
        let action: (Course) -> Void = {_ in }
        let mainSection = CourseInfoSection(.main(hosts: [hosts], descr: descr, imageURL: imageURL, introVideo: introVideo, subscriptionAction: action), title: title)

        let summary = course.summary
        let summarySection = CourseInfoSection(.text(content: summary), title: "Summary")

        let workload = course.audience
        let workloadSection = CourseInfoSection(.text(content: workload), title: "Audience")

        let format = course.format
        let formatSection = CourseInfoSection(.text(content: format), title: "Format")

        return [mainSection, summarySection, workloadSection, formatSection]
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
    case main(hosts: [String], descr: String, imageURL: URL?, introVideo: Video?, subscriptionAction: (Course) -> Void)
    case text(content: String)
    case instructors

    var viewClass: CourseInfoSectionView.Type {
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
