//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DeepLinkRouter {
    
    static func routeFromDeepLink(link: NSURL, completion: (UIViewController?, Bool) -> Void) {
        
        func getID(stringId: String, reversed: Bool) -> Int? {
            var slugString = ""
            let string = reversed ? String(stringId.characters.reverse()) : stringId
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
        
                
        guard let components = link.pathComponents else {
            completion(nil, false)
            return
        }
            //just a check if everything is OK with the link length
            
        if components[1].lowercaseString == "course" && components.count >= 3 {
            guard let courseId = getID(components[2], reversed: true) else {
                completion(nil, false)
                return
            }
            
            if components.count == 3 {
                routeToCourseWithId(courseId, completion: completion)
                return
            }
    
            if components.count == 4 && components[3].lowercaseString.containsString("syllabus") {
                routeToSyllabusWithId(courseId, completion: completion)
                return
            }
            
            completion(nil, false)
            return
        }  
            
            
        if components[1].lowercaseString == "lesson" && components.count >= 5 {
            guard let lessonId = getID(components[2], reversed: true) else {
                completion(nil, false)
                return
            }
            
            guard components[3].lowercaseString == "step" else {
                completion(nil, false)
                return
            }
            
            guard let stepId = getID(components[4], reversed: false) else {
                completion(nil, false)
                return
            }
            
            routeToStepWithId(stepId, lessonId: lessonId, completion: completion)
            return
        }            
         
        completion(nil, false)
        return
    }
    
    private static func routeToCourseWithId(courseId: Int, completion: (UIViewController?, Bool) -> Void) {
        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
            do {
                let courses = try Course.getCourses([courseId])
                if courses.count == 0 {
                    performRequest({
                        ApiDataDownloader.sharedDownloader.getCoursesByIds([courseId], deleteCourses: [], refreshMode: .Delete, success: {
                            loadedCourses in 
                            if loadedCourses.count == 1 {
                                UIThread.performUI {
                                    vc.course = loadedCourses[0]
                                    completion(vc, true)
                                }
                            } else {
                                print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                completion(nil, false)
                                return
                            }
                            }, failure: {
                                error in
                                print("error while downloading course with id \(courseId)")
                                completion(nil, false) 
                                return
                        })
                    })
                    return
                } 
                if courses.count == 1 {
                    vc.course = courses[0]
                    completion(vc, true)
                    return
                }
                completion(nil, false)
                return
            }
            catch {
                print("something bad happened")
                completion(nil, false)
                return
            }
        }
        
        completion(nil, false)
    }
    
    private static func routeToSyllabusWithId(courseId: Int, completion: (UIViewController?, Bool) -> Void) {
        do {
            let courses = try Course.getCourses([courseId])
            if courses.count == 0 {
                performRequest({
                    ApiDataDownloader.sharedDownloader.getCoursesByIds([courseId], deleteCourses: [], refreshMode: .Delete, success: {
                        loadedCourses in 
                        if loadedCourses.count == 1 {
                            UIThread.performUI {
                                let course = loadedCourses[0]
                                if course.enrolled {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                                        vc.course = course
                                        completion(vc, true)
                                    }
                                } else {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                        vc.course = course
                                        vc.displayingInfoType = DisplayingInfoType.Syllabus
                                        completion(vc, true)
                                    }
                                }
                            }
                        } else {
                            print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                            completion(nil, false)
                            return
                        }
                        }, failure: {
                            error in
                            print("error while downloading course with id \(courseId)")
                            completion(nil, false) 
                            return
                    })
                })
                return
            } 
            if courses.count == 1 {
                let course = courses[0]
                if course.enrolled {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                        vc.course = course
                        completion(vc, true)
                    }
                } else {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                        vc.course = course
                        vc.displayingInfoType = DisplayingInfoType.Syllabus
                        completion(vc, true)
                    }
                }
                return
            }
            completion(nil, false)
            return
        }
        catch {
            print("something bad happened")
            completion(nil, false)
            return
        }        
    }
    
    static func routeToStepWithId(stepId: Int, lessonId: Int, completion: (UIViewController?, Bool) -> Void) {
        let router = StepsControllerDeepLinkRouter()
        router.getStepsViewControllerFor(step: stepId, inLesson: lessonId, success: 
            {
                vc in
                completion(vc, true)
            }, error: 
            {
                errorMsg in 
                print(errorMsg)
                completion(nil, false)
            }
        )

    }
}