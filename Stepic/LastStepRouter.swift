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
        if AdaptiveStorageManager.shared.canOpenInAdaptiveMode(courseId: course.id) {
            guard let cardsViewController = ControllerHelper.instantiateViewController(identifier: "CardsSteps", storyboardName: "Adaptive") as? BaseCardsStepsViewController else {
                return
            }
            cardsViewController.hidesBottomBarWhenPushed = true
            cardsViewController.course = course
            navigationController.pushViewController(cardsViewController, animated: true)
            SVProgressHUD.showSuccess(withStatus: "")
            return
        }

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

        func navigateToStep(in unit: Unit) {
            // If last step does not exist then take first step in unit
            unitsVC.unitId = course.lastStep?.unitId ?? unit.id

            let stepIdPromise = Promise<Int> { fulfill, reject in
                if let stepId = course.lastStep?.stepId {
                    fulfill(stepId)
                } else {
                    let cachedLesson = unit.lesson ?? Lesson.getLesson(unit.lessonId)
                    ApiDataDownloader.lessons.retrieve(ids: [unit.lessonId], existing: cachedLesson == nil ? [] : [cachedLesson!]).then { lessons -> Void in
                        if let lesson = lessons.first {
                            unit.lesson = lesson
                        }

                        if let firstStepId = lessons.first?.stepsArray.first {
                            fulfill(firstStepId)
                        } else {
                            reject(NSError(domain: "error", code: 100, userInfo: nil)) // meh.
                        }
                    }.catch { _ in
                        reject(NSError(domain: "error", code: 100, userInfo: nil)) // meh.
                    }
                }
            }

            stepIdPromise.then { targetStepId -> Void in
                lessonVC.initIds = (stepId: targetStepId, unitId: unit.id)
                lessonVC.sectionNavigationDelegate = unitsVC

                SVProgressHUD.showSuccess(withStatus: "")
                navigationController.pushViewController(sectionsVC, animated: false)
                navigationController.pushViewController(unitsVC, animated: false)
                navigationController.pushViewController(lessonVC, animated: true)
                LocalProgressLastViewedUpdater.shared.updateView(for: course)
                AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.stepOpened, parameters: nil)
            }.catch { _ in
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
                        navigateToStep(in: unit)
                    } else {
                        openSyllabus()
                    }
                } else {
                    print("last step router: section not found, id = \(unit.sectionId)")
                    openSyllabus()
                }
            }, error: { err in
                print("last step router: error while loading section, error = \(err)")

                // Fallback: use cached section 
                guard let section = sectionForUpdate else {
                    openSyllabus()
                    return
                }

                print("last step router: using cached section")
                if section.isReachable {
                    navigateToStep(in: unit)
                } else {
                    openSyllabus()
                }
            })
        }

        guard let unitId = course.lastStep?.unitId else {
            // If last step does not exist then take first section and its first unit
            guard let sectionId = course.sectionsArray.first,
                  let sections = try? Section.getSections(sectionId),
                  let cachedSection = sections.first else {
                openSyllabus()
                return
            }

            ApiDataDownloader.sections.retrieve(ids: [sectionId], existing: [cachedSection]).then { section -> Void in
                guard let unitId = section.first?.unitsArray.first else {
                    print("last step router: section has no units")
                    return
                }
                checkUnitAndNavigate(for: unitId)
            }.catch { _ in
                print("last step router: unable to load section when last step does not exists")
                openSyllabus()
            }
            return
        }

        checkUnitAndNavigate(for: unitId)
    }
}
