//
//  CourseInfoPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import PromiseKit

let LOADING_CONST: Double = 1.0

extension NSNotification.Name {
    static let subscribe = NSNotification.Name("subscribe")
}

class CourseInfoPresenter {

    private weak var view: CourseInfoView?
    private var subscriber: CourseSubscriber

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
    private var instructors: [User] = []
    private var sections: [CourseInfoSection] = []

    init(view: CourseInfoView) {
        self.view = view
        self.subscriber = CourseSubscriber()
    }

    private func buildSections(with course: Course) -> [CourseInfoSection] {
        guard let viewController = view as? UIViewController else { fatalError() }

        var sections: [CourseInfoSection] = []

        let textSelectionAction: (TVFocusableText) -> Void = {
            let textPresenter = TVTextPresentationAlertController()
            textPresenter.setText($0.text ?? "")
            textPresenter.modalPresentationStyle = .overFullScreen
            viewController.present(textPresenter, animated: true, completion: {})
        }

        // Main section
        let mainSection = createMainSection(course: course, selectionAction: textSelectionAction)
        sections.append(mainSection)

        // Instructors section
        if let instructorsSections = createInstructorsSection(selectionAction: textSelectionAction) {
            sections.append(instructorsSections)
        }

        // Details sections
        let detailsSections = createDetailSections(course: course, selectionAction: textSelectionAction)
        sections.append(contentsOf: detailsSections)

        return sections
    }

    private func createMainSection(course: Course, selectionAction: @escaping (TVFocusableText) -> Void) -> CourseInfoSection {
        let title = course.title
        let descr = course.courseDescription
        let imageURL = URL(string: course.coverURLString)

        let trailerAction: () -> Void = { _ in
            self.playIntro(intro: course.introVideo)
        }

        let subscriptionAction: () -> Void = { _ in
            self.subscribe(to: course, delete: course.enrolled)
        }

        let section = CourseInfoSection(.main(hosts: [""], descr: descr, imageURL: imageURL, trailerAction: trailerAction, subscriptionAction: subscriptionAction, selectionAction: selectionAction, enrolled: course.enrolled), title: title)
        return section
    }

    private func createDetailSections(course: Course, selectionAction: @escaping (TVFocusableText) -> Void) -> [CourseInfoSection] {
        let detailsParams = ["Audience": course.audience, "Certificate": course.certificate, "Requirements": course.requirements , "Workload": course.workload, "Summary": course.summary].filter {
            $0.value != ""
        }
        let sections = detailsParams.map {
            CourseInfoSection(.text(content: $0.value, selectionAction: selectionAction), title: $0.key)
        }
        return sections
    }

    private func createInstructorsSection(selectionAction: @escaping (TVFocusableText) -> Void) -> CourseInfoSection? {
        let instructorsViewData = instructors.map {
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: $0.avatarURL, title: "\($0.lastName) \($0.firstName)") { }
        }

        guard instructorsViewData.count != 0 else { return nil }

        let instructorsSection = CourseInfoSection(.instructors(items: instructorsViewData), title: "Instructors")
        return instructorsSection
    }

    private func playIntro(intro: Video?) {
        guard let viewController = view as? UIViewController else { fatalError() }
        guard let intro = intro else { return }

        let player = TVPlayerViewController()
            player.video = intro

        viewController.present(player, animated: true) {}
    }

    private func subscribe(to course: Course, delete: Bool = false) {
        checkToken().then {
            [weak self]
            () -> Promise<Course> in
            guard let strongSelf = self else {
                throw CourseSubscriber.CourseSubscriptionError.error(status: "")
            }
            return strongSelf.subscriber.join(course: course, delete: delete)
            }.then {
                [weak self]
                course -> Void in
                guard let strongSelf = self else { return }
                strongSelf.course?.enrolled = !delete
                strongSelf.view?.provide(sections: strongSelf.buildSections(with: course))
            }.catch {
                error in
                print("error: " + error.localizedDescription)
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
    case main(hosts: [String], descr: String, imageURL: URL?, trailerAction: () -> Void, subscriptionAction: () -> Void, selectionAction: (TVFocusableText) -> Void, enrolled: Bool)
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
