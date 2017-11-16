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

        func openSyllabus() {
            SVProgressHUD.showSuccess(withStatus: "")
            navigationController.pushViewController(sectionsVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.sectionsOpened, parameters: nil)
            return
        }

        func checkUnitAndNavigate(for unitId: Int) {
            if let unit = Unit.getUnit(id: unitId) {
                checkSectionAndNavigate(in: unit)
            } else {
                ApiDataDownloader.units.retrieve(ids: [unitId], existing: [], refreshMode: .update, success: { units in
                    if let unit = units.first {
                        checkSectionAndNavigate(in: unit)
                    } else {
                        print("last step router: unit not found, id = \(unitId)")
                        openSyllabus()
                    }
                }, error: { err in
                    print("last step router: error while loading unit, error = \(err)")
                    openSyllabus()
                })
            }
        }

        func navigateToStep() {
            unitsVC.unitId = course.lastStep?.unitId
            lessonVC.initIds = (stepId: course.lastStep?.stepId, unitId: course.lastStep?.unitId)

            //For prev-next step buttons navigation
            lessonVC.sectionNavigationDelegate = unitsVC

            if course.lastStep?.stepId != nil {
                SVProgressHUD.showSuccess(withStatus: "")
                navigationController.pushViewController(sectionsVC, animated: false)
                navigationController.pushViewController(unitsVC, animated: false)
                navigationController.pushViewController(lessonVC, animated: true)
                AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.stepOpened, parameters: nil)
            } else {
                openSyllabus()
            }
        }

        func checkSectionAndNavigate(in unit: Unit) {
            var sectionForUpdate: Section? = nil
            if let retrievedSections = try? Section.getSections(unit.sectionId),
               let section = retrievedSections.first {
                sectionForUpdate = section
            }

            // Always refresh section to prevent obsolete `isReachable` state
            ApiDataDownloader.sections.retrieve(ids: [unit.sectionId], existing: sectionForUpdate == nil ? [] : [sectionForUpdate!], refreshMode: .update, success: { sections in
                if let section = sections.first {
                    unit.section = section
                    CoreDataHelper.instance.save()

                    if section.isReachable {
                        navigateToStep()
                    } else {
                        openSyllabus()
                    }
                } else {
                    print("last step router: section not found, id = \(unit.sectionId)")
                    openSyllabus()
                }
            }, error: { err in
                print("last step router: error while loading section, error = \(err)")
                openSyllabus()
            })
        }

        guard let unitId = course.lastStep?.unitId else {
            openSyllabus()
            return
        }

        checkUnitAndNavigate(for: unitId)
    }
}
