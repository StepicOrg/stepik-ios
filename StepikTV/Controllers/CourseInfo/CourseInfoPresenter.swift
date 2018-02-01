//
//  CourseInfoPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

let LOADING_CONST: Double = 1.0

class CourseInfoPresenter {

    private weak var view: CourseInfoView?

    var course: Course? {
        didSet {
            guard let course = course else { return }
            view?.showLoading(title: course.title)
            let beginLoadTimestamp = Date().timeIntervalSince1970

            course.loadAllInstructors {
                let endLoadTimestamp = Date().timeIntervalSince1970
                let diff = LOADING_CONST - endLoadTimestamp + beginLoadTimestamp

                self.instructors = course.instructors
                self.view?.provide(sections: self.buildSections(with: course))

                DispatchQueue.main.asyncAfter(deadline: .now() + diff) {
                    [weak self] in
                    self?.view?.hideLoading()
                }
            }
        }
    }
    private var instructors: [User]?
    private var sections: [CourseInfoSection] = []

    init(view: CourseInfoView) {
        self.view = view
    }

    private func buildSections(with course: Course) -> [CourseInfoSection] {
        guard let viewController = view as? UIViewController else { fatalError() }

        let title = course.title
        let hosts = ""
        let descr = course.courseDescription
        let imageURL = URL(string: course.coverURLString)
        let trailerAction: () -> Void = { _ in
            self.playIntro(intro: course.introVideo)
        }
        let subscriptionAction: (Course) -> Void = {_ in }

        let selectionAction: (TVFocusableText) -> Void = {
            let textPresenter = TVTextPresentationAlertController()
            textPresenter.setText($0.text ?? "")
            textPresenter.modalPresentationStyle = .overFullScreen
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

    private func playIntro(intro: Video?) {
        guard let viewController = view as? UIViewController else { fatalError() }
        guard let url = intro?.getUrlForQuality("720") else { return }

        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player

        viewController.present(controller, animated: true) {
            player.play()
        }
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
    case main(hosts: [String], descr: String, imageURL: URL?, trailerAction: () -> Void, subscriptionAction: (Course) -> Void, selectionAction: (TVFocusableText) -> Void)
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
