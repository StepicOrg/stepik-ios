//
//  CourseContentView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

protocol MenuCourseContentView: class {

    func provide(courseInfo: CourseViewData)

    func provide(sections: [SectionViewData])

}

protocol DetailCourseContentView: class {

    func update()

    func showLoading(isVisible: Bool)

}
