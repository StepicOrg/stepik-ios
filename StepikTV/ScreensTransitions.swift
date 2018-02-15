//
//  ScreensTransitions.swift
//  StepikTV
//
//  Created by Александр Пономарев on 03.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ScreensTransitions {

    class func moveToCourseInformationScreen(from viewController: UIViewController, for course: Course) {

        let destinationViewController = ControllerHelper.instantiateViewController(identifier: "CourseInfoPage", storyboardName: "CourseInfo") as! CourseInfoCollectionViewController

        destinationViewController.presenter = CourseInfoPresenter(view: destinationViewController)
        destinationViewController.presenter?.course = course

        viewController.present(destinationViewController, animated: true, completion: {})
    }

    class func moveToTagCoursesScreen(from viewController: UIViewController, for tag: CourseTag, title: String) {

        let navigationController = ControllerHelper.instantiateViewController(identifier: "TagCoursesNavigation", storyboardName: "TagCourses") as! UINavigationController

        let destinationViewController = navigationController.viewControllers.first as! TagCoursesCollectionViewController

        destinationViewController.navigationItem.title = title

        destinationViewController.presenter = TagCoursesCollectionPresenter(view: destinationViewController, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI())
        destinationViewController.presenter?.tag = tag

        viewController.present(navigationController, animated: true, completion: {})
    }

    class func moveToCourseContent(from viewController: UIViewController, for course: Course) {

        let initialNavController = ControllerHelper.instantiateViewController(identifier: "CourseContentInitial", storyboardName: "CourseContent") as! UINavigationController

        let splitViewController = initialNavController.viewControllers.first as! MenuSplitViewController

        let navigationController = splitViewController.viewControllers.first as! UINavigationController

        let destinationViewController = navigationController.viewControllers.first as! CourseContentMenuViewController

        destinationViewController.presenter = CourseContentPresenter(view: destinationViewController)
        destinationViewController.presenter?.course = course

        viewController.present(initialNavController, animated: true, completion: {})
    }

}
