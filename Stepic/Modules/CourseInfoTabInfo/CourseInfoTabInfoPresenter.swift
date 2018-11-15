//
//  CourseInfoTabInfoPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoTabInfoPresenterProtocol {
    func presentCourseInfo(response: CourseInfoTabInfo.ShowInfo.Response)
}

final class CourseInfoTabInfoPresenter: CourseInfoTabInfoPresenterProtocol {
    weak var viewController: CourseInfoTabInfoViewControllerProtocol?

    func presentCourseInfo(response: CourseInfoTabInfo.ShowInfo.Response) {
        var viewModel: CourseInfoTabInfo.ShowInfo.ViewModel

        if let course = response.course {
            viewModel = .init(state: .result(data: self.courseToViewModel(course: course)))
        } else {
            viewModel = .init(state: .loading)
        }

        self.viewController?.displayCourseInfo(viewModel: viewModel)
    }

    // MARK: Prepare view data

    private func courseToViewModel(course: Course) -> CourseInfoTabInfoViewModel {
        return CourseInfoTabInfoViewModel(
            author: "Yandex",
            introVideoURL: URL(string: "https://player.vimeo.com/external/161974070.hd.mp4?s=19ff926134e7cbbc7e8ce161e3af9c3bb87d5c1a&profile_id=174&oauth2_token_id=3605157?playsinline=1"),
            aboutText: "This course was designed for beginner java developers and people who'd like to learn functional approach to programming. If you are an expert in java or functional programming this course will seem too simple for you. It would be better for you to proceed to a more advanced course.",
            requirementsText: "Basic knowledge of Java syntax, collections, OOP and pre-installed JDK 8+.",
            targetAudienceText: "People who would like to improve their skills in java programming and to learn functional programming",
            timeToCompleteText: "11 hours",
            languageText: "English",
            certificateText: "Yes",
            certificateDetailsText: "Certificate condition: 50 points\nWith distinction: 75 points",
            instructors: [
                .init(
                    avatarImageURL: URL(string: "https://www.w3schools.com/howto/img_avatar.png"),
                    title: "Artyom Burylov",
                    description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                ),
                .init(
                    avatarImageURL: URL(string: "https://www.w3schools.com/w3images/avatar2.png"),
                    title: "Tom Tom",
                    description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                )
            ]
        )
    }
}
