//
//  LastStepRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SVProgressHUD

enum LastStepError: Error {
    case multipleLastSteps
}

class LastStepRouter {
    static func continueLearning(for course: Course, using navigationController: UINavigationController) {
        guard let lastStepId = course.lastStepId else {
            return
        }
        SVProgressHUD.show()
        ApiDataDownloader.lastSteps.getObjectsByIds(ids: [lastStepId], updating: course.lastStep != nil ? [course.lastStep!] : []).then {
            newLastSteps -> Void in
            guard let newLastStep = newLastSteps.first else {
                throw LastStepError.multipleLastSteps
            }

            course.lastStep = newLastStep
            CoreDataHelper.instance.save()
        }.always {
            SVProgressHUD.showSuccess(withStatus: "")
            navigate(for: course, using: navigationController)
        }.catch {
            _ in
            print("error while updating lastStep")
        }
    }

    private static func navigate(for course: Course, using navigationController: UINavigationController) {
        guard
            let sectionsVC = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController,
            let unitsVC = ControllerHelper.instantiateViewController(identifier: "UnitsViewController") as? UnitsViewController,
            let lessonVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
                return
        }

        sectionsVC.course = course
        sectionsVC.hidesBottomBarWhenPushed = true
        unitsVC.unitId = course.lastStep?.unitId

        lessonVC.initIds = (stepId: course.lastStep?.stepId, unitId: course.lastStep?.unitId)

        //For prev-next step buttons navigation
        lessonVC.sectionNavigationDelegate = unitsVC

        if course.lastStep?.unitId != nil && course.lastStep?.stepId != nil {
            navigationController.pushViewController(sectionsVC, animated: false)
            navigationController.pushViewController(unitsVC, animated: false)
            navigationController.pushViewController(lessonVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.stepOpened, parameters: nil)
        } else {
            navigationController.pushViewController(sectionsVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.sectionsOpened, parameters: nil)
        }
    }
}
