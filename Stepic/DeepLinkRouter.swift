//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DeepLinkRouter {
    
    static func routeFromDeepLink(link: NSURL, completion: (UIViewController? -> Void)) {
        func getCourseID(string: String) -> Int? {
            var courseString = ""
            for character in string.characters.reverse() {
                if Int("\(character)") != nil {
                    courseString = "\(character)" + courseString
                } else {
                    break
                }
            }
            let courseId = Int(courseString)
            
            return courseId
        }
        
        if let components = link.pathComponents {
            //just a check if everything is OK with the link length
            if components.count < 2 {
                completion(nil)
                return 
            }
            
            if components[1].lowercaseString == "course" {
                if let courseId = getCourseID(components[2]) {
                    if components.count == 3 {
                        routeToCourseWithId(courseId, completion: completion)
                        return
                    }
                    if components.count == 4 && components[3].lowercaseString.containsString("syllabus") {
                        routeToSyllabusWithId(courseId, completion: completion)
                        return
                    }
                    completion(nil)
                    return
                } else {
                    completion(nil)
                    return
                }
            } else {
                completion(nil)
                return
            }
        } else {
            completion(nil)
            return
        }
    }
    
    private static func routeToCourseWithId(courseId: Int, completion: (UIViewController? -> Void)) {
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
                                    completion(vc)
                                }
                            } else {
                                print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                completion(nil)
                                    return
                                }
                            }, failure: {
                                error in
                                print("error while downloading course with id \(courseId)")
                                completion(nil) 
                                return
                        })
                    })
                    return
                } 
                if courses.count == 1 {
                    vc.course = courses[0]
                    completion(vc)
                    return
                }
                completion(nil)
                return
            }
            catch {
                print("something bad happened")
                completion(nil)
                return
            }
        }
        
        completion(nil)
    }
    
    private static func routeToSyllabusWithId(courseId: Int, completion: (UIViewController? -> Void)) {
        if !AuthInfo.shared.isAuthorized {
                do {
                    let courses = try Course.getCourses([courseId])
                    if courses.count == 0 {
                        performRequest({
                            ApiDataDownloader.sharedDownloader.getCoursesByIds([courseId], deleteCourses: [], refreshMode: .Delete, success: {
                                loadedCourses in 
                                if loadedCourses.count == 1 {
                                    UIThread.performUI {
                                        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                            vc.course = loadedCourses[0]
                                            completion(vc)
                                        }
                                    }
                                } else {
                                    print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                    completion(nil)
                                    return
                                }
                                }, failure: {
                                    error in
                                    print("error while downloading course with id \(courseId)")
                                    completion(nil) 
                                    return
                            })
                        })
                        return
                    } 
                    if courses.count == 1 {
                        UIThread.performUI {
                            if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                vc.course = courses[0]
                                completion(vc)
                            }
                        }
                        return
                    } else {
                        completion(nil)
                    }
                    return
                }
                catch {
                    print("something bad happened")
                    completion(nil)
                    return
                }
        } else {
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
                                            completion(vc)
                                        }
                                    } else {
                                        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                            vc.course = course
                                            vc.displayingInfoType = DisplayingInfoType.Syllabus
                                            completion(vc)
                                        }
                                    }
                                }
                            } else {
                                print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                completion(nil)
                                return
                            }
                            }, failure: {
                                error in
                                print("error while downloading course with id \(courseId)")
                                completion(nil) 
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
                            completion(vc)
                        }
                    } else {
                        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                            vc.course = course
                            vc.displayingInfoType = DisplayingInfoType.Syllabus
                            completion(vc)
                        }
                    }
                    return
                }
                completion(nil)
                return
            }
            catch {
                print("something bad happened")
                completion(nil)
                return
            }
        }
        
        completion(nil)
    }
}