//
//  CertificatesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CertificatesPresenter {
   
    weak var view : CertificatesView?
    private var certificatesAPI : CertificatesAPI?
    private var coursesAPI : CoursesAPI?
    
    init(certificatesAPI: CertificatesAPI, coursesAPI: CoursesAPI) {
        self.certificatesAPI = certificatesAPI
    }
    
    private var page : Int = 1
    private var certificates: [Certificate] = []
    
    func refreshCertificates() {
        guard let userId = AuthInfo.shared.userId else {
            certificates = []
            view?.displayAnonymous()
            return
        }
        
        certificates = []
        
        certificatesAPI?.retrieve(userId: userId, success: {
            [weak self]
            meta, newCertificates in
            
            self?.certificates = newCertificates
            
            self?.loadCoursesForCertificates(certificates: newCertificates, completion: {
                [weak self] in
                guard let s = self else {
                    return
                }
                s.view?.setCertificates(certificates: s.certificates.flatMap({
                    [weak self] in
                    return self?.certificateViewData(fromCertificate: $0)
                }), hasNextPage: meta.hasNext)
            })
        }, error: {
            [weak self]
            error in
            self?.view?.displayError()
        })
    }
    
    private func loadCoursesForCertificates(certificates: [Certificate], completion: @escaping (Void) -> Void) {
        func matchCoursesToCertificates(courses: [Course]) {
            for certificate in certificates {
                if let filtered = courses.filter({$0.id == certificate.courseId}).first {
                    certificate.course = filtered
                }
            }
        }
        
        let courseIds = certificates.map {
            return $0.courseId
        }
        
        let localCourses = try! Course.getCourses(courseIds)
        matchCoursesToCertificates(courses: localCourses)
        
        coursesAPI?.retrieve(ids: courseIds, existing: localCourses, refreshMode: .update, success: {
            courses in
            matchCoursesToCertificates(courses: courses)
            completion()
        }, error: {
            error in
            completion()
        })
    }
    
    private func certificateViewData(fromCertificate certificate: Certificate) -> CertificateViewData {
        
        var courseImageURL : URL? = nil
        if let courseImageURLString = certificate.course?.coverURLString {
            courseImageURL = URL(string: courseImageURLString)
        }
        
        var certificateURL : URL? = nil
        if let certificateURLString = certificate.urlString {
            certificateURL = URL(string: certificateURLString)
        }
        
        return CertificateViewData(courseName: certificate.course?.title, courseImageURL: courseImageURL, grade: certificate.grade, certificateURL: certificateURL)
    }
    
    func getNextPage() {
        guard let userId = AuthInfo.shared.userId else {
            certificates = []
            view?.displayAnonymous()
            return
        }

        certificatesAPI?.retrieve(userId: userId, page: page + 1, success: {
            [weak self]
            meta, newCertificates in
            self?.page += 1
            self?.certificates += newCertificates
            
            self?.loadCoursesForCertificates(certificates: newCertificates, completion: {
                [weak self] in
                guard let s = self else {
                    return
                }
                s.view?.setCertificates(certificates: s.certificates.flatMap({
                    [weak self] in
                    return self?.certificateViewData(fromCertificate: $0)
                }), hasNextPage: meta.hasNext)            })
        }, error: {
            [weak self]
            error in
            self?.view?.displayLoadNextPageError()
        })
    }
}
