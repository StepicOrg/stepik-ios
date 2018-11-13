//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoTabInfoViewController: UIViewController {
    private lazy var courseInfoView = self.view as? CourseInfoTabInfoView

    // MARK: - Lifecycle

    override func loadView() {
        self.view = CourseInfoTabInfoView(blockViewBuilder: CourseInfoTabInfoBlockViewBuilder.build)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: For testing
        self.courseInfoView?.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.courseInfoView?.hideLoading()
            self.courseInfoView?.configure(viewModel: self.getViewModel())
        }
    }

    // TODO: For testing
    private func getViewModel() -> CourseInfoTabInfoViewModel {
        return CourseInfoTabInfoViewModel(blocks: [
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .author("Yandex"), message: ""
            ),
            CourseInfoTabInfoIntroVideoBlockViewModel(
                introURL: URL(string: "https://player.vimeo.com/external/161974070.hd.mp4?s=19ff926134e7cbbc7e8ce161e3af9c3bb87d5c1a&profile_id=174&oauth2_token_id=3605157?playsinline=1")
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .about,
                message: "This course was designed for beginner java developers and people who'd like to learn functional approach to programming. If you are an expert in java or functional programming this course will seem too simple for you. It would be better for you to proceed to a more advanced course."
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .requirements,
                message: "Basic knowledge of Java syntax, collections, OOP and pre-installed JDK 8+."
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .targetAudience,
                message: "People who would like to improve their skills in java programming and to learn functional programming"
            ),
            CourseInfoTabInfoInstructorsBlockViewModel(
                instructors: [
                    CourseInfoTabInfoInstructorViewModel(
                        avatarURL: URL(string: "https://www.w3schools.com/howto/img_avatar.png"),
                        title: "Artyom Burylov",
                        description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                    ),
                    CourseInfoTabInfoInstructorViewModel(
                        avatarURL: URL(string: "https://www.w3schools.com/w3images/avatar2.png"),
                        title: "Tom Tom",
                        description: "Kotlin backend developer, online education enthusiast. I graduated from PNRPU with a BSc in Computer Science (2014) and MSc in Software Engineering (2016). During the learning, I took an active part in scientific conferences and educational events."
                    )
                ]
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .timeToComplete, message: "11 hours"
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .language, message: "English"
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .certificate,
                message: "Yes"
            ),
            CourseInfoTabInfoTextBlockViewModel(
                blockType: .certificateDetails,
                message: "Certificate condition: 50 points\nWith distinction: 75 points"
            )
        ])
    }
}
