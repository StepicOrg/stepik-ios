//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DeepLinkRouter {
    
    static func routeFromDeepLink(_ link: URL, completion: @escaping ([UIViewController]) -> Void) {
        
        func getID(_ stringId: String, reversed: Bool) -> Int? {
            var slugString = ""
            let string = reversed ? String(stringId.characters.reversed()) : stringId
            for character in string.characters {
                if Int("\(character)") != nil {
                    if reversed {
                        slugString = "\(character)" + slugString
                    } else {
                        slugString = slugString + "\(character)"
                    }
                } else {
                    break
                }
            }
            let slugId = Int(slugString)
            
            return slugId
        }
        
                
        let components = link.pathComponents 
            //just a check if everything is OK with the link length
            
        if components[1].lowercased() == "course" && components.count >= 3 {
            guard let courseId = getID(components[2], reversed: true) else {
                completion([])
                return
            }
            
            if components.count == 3 {
                AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.course, parameters: ["id": courseId as NSObject])
                routeToCourseWithId(courseId, completion: completion)
                return
            }
    
            if components.count == 4 && components[3].lowercased().contains("syllabus") {
                
                if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems  {
                    if let module = queryItems.filter({ (item) in item.name == "module" }).first?.value! {
                        if let moduleInt = Int(module) {
                            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.section, parameters: ["course": courseId as NSObject, "module": module as NSObject])
                            routeToSyllabusWithId(courseId, moduleId: moduleInt, completion: completion)
                            return
                        }
                    }
                } 
                
                AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.syllabus, parameters: ["id": courseId as NSObject])
                routeToSyllabusWithId(courseId, completion: completion)
                return
            }
            
            completion([])
            return
        }  
            
            
        if components[1].lowercased() == "lesson" && components.count >= 5 {
            guard let lessonId = getID(components[2], reversed: true) else {
                completion([])
                return
            }
            
            guard components[3].lowercased() == "step" else {
                completion([])
                return
            }
            
            guard let stepId = getID(components[4], reversed: false) else {
                completion([])
                return
            }
            
            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.step, parameters: ["lesson": lessonId as NSObject, "step": stepId as NSObject])
            routeToStepWithId(stepId, lessonId: lessonId, completion: completion)
            return
        }            
         
        completion([])
        return
    }
    
    fileprivate static func routeToCourseWithId(_ courseId: Int, completion: @escaping ([UIViewController]) -> Void) {
        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
            do {
                let courses = try Course.getCourses([courseId])
                if courses.count == 0 {
                    performRequest({
                        _ = ApiDataDownloader.sharedDownloader.getCoursesByIds([courseId], deleteCourses: [], refreshMode: .delete, success: {
                            loadedCourses in 
                            if loadedCourses.count == 1 {
                                UIThread.performUI {
                                    vc.course = loadedCourses[0]
                                    completion([vc])
                                }
                            } else {
                                print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                completion([])
                                return
                            }
                            }, failure: {
                                error in
                                print("error while downloading course with id \(courseId)")
                                completion([]) 
                                return
                        })
                    })
                    return
                } 
                if courses.count >= 1 {
                    vc.course = courses[0]
                    completion([vc])
                    return
                }
                completion([])
                return
            }
            catch {
                print("something bad happened")
                completion([])
                return
            }
        }
        
        completion([])
    }
    
    fileprivate static func routeToSyllabusWithId(_ courseId: Int, moduleId: Int? = nil, completion: @escaping ([UIViewController]) -> Void) {
        do {
            let courses = try Course.getCourses([courseId])
            if courses.count == 0 {
                performRequest({
                    _ = ApiDataDownloader.sharedDownloader.getCoursesByIds([courseId], deleteCourses: [], refreshMode: .delete, success: {
                        loadedCourses in 
                        if loadedCourses.count == 1 {
                            UIThread.performUI {
                                let course = loadedCourses[0]
                                if course.enrolled {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                                        vc.course = course
                                        vc.moduleId = moduleId
                                        completion([vc])
                                    }
                                } else {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                        vc.course = course
                                        vc.displayingInfoType = DisplayingInfoType.syllabus
                                        completion([vc])
                                    }
                                }
                            }
                        } else {
                            print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                            completion([])
                            return
                        }
                        }, failure: {
                            error in
                            print("error while downloading course with id \(courseId)")
                            completion([]) 
                            return
                    })
                })
                return
            } 
            if courses.count >= 1 {
                let course = courses[0]
                if course.enrolled {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                        vc.course = course
                        vc.moduleId = moduleId
                        completion([vc])
                    }
                } else {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                        vc.course = course
                        vc.displayingInfoType = DisplayingInfoType.syllabus
                        completion([vc])
                    }
                }
                return
            }
            completion([])
            return
        }
        catch {
            print("something bad happened")
            completion([])
            return
        }        
    }
    
    static func routeToStepWithId(_ stepId: Int, lessonId: Int, completion: @escaping ([UIViewController]) -> Void) {
        let router = StepsControllerDeepLinkRouter()
        router.getStepsViewControllerFor(step: stepId, inLesson: lessonId, success: 
            {
                vc in
                completion([vc])
            }, error: 
            {
                errorMsg in 
                print(errorMsg)
                completion([])
            }
        )

    }
}
