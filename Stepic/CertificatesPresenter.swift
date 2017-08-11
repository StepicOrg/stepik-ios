//
//  CertificatesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CertificatesPresenter {

    weak var view: CertificatesView?
    private var certificatesAPI: CertificatesAPI?
    private var coursesAPI: CoursesAPI?
    private var presentationContainer: CertificatesPresentationContainer?

    private var lastRefreshedUserId: Int?

    init(certificatesAPI: CertificatesAPI, coursesAPI: CoursesAPI, presentationContainer: CertificatesPresentationContainer, view: CertificatesView) {
        self.certificatesAPI = certificatesAPI
        self.coursesAPI = coursesAPI
        self.presentationContainer = presentationContainer
        self.view = view
        guard let userId = AuthInfo.shared.userId,
            AuthInfo.shared.isAuthorized else {
                certificates = []
                lastRefreshedUserId = nil
                view.displayAnonymous()
                return
        }

        getCachedCertificates(userId: userId)
    }

    var page: Int = 1
    var certificates: [Certificate] = [] {
        didSet {
            self.updatePersistentPresentationData()
        }
    }

    func checkStatus() {
        if lastRefreshedUserId != AuthInfo.shared.userId {
            certificates = []
            lastRefreshedUserId = AuthInfo.shared.userId
            if !AuthInfo.shared.isAuthorized {
                view?.displayAnonymous()
                view?.setCertificates(certificates: [], hasNextPage: false)
            } else {
                view?.displayEmpty()
                view?.setCertificates(certificates: [], hasNextPage: false)
                refreshCertificates()
            }
        }
    }

    func getCachedCertificates(userId: Int) {
        guard let localIds = presentationContainer?.certificatesIds else {
            return
        }

        let localCertificates = Certificate.fetch(localIds, user: userId).sorted(by: {
            guard let index1 = localIds.index(of: $0.id),
                let index2 = localIds.index(of: $1.id) else {
                    return false
            }
            return index1 < index2
        }).flatMap {
            [weak self] in
            return self?.certificateViewData(fromCertificate: $0)
        }

        view?.setCertificates(certificates: localCertificates, hasNextPage: false)
    }

    fileprivate func updatePersistentPresentationData() {
        presentationContainer?.certificatesIds = certificates.map({
            return $0.id
        })
    }

    func refreshCertificates() {
        guard let userId = AuthInfo.shared.userId,
            AuthInfo.shared.isAuthorized else {
            certificates = []
            lastRefreshedUserId = nil
            view?.displayAnonymous()
            return
        }

        lastRefreshedUserId = userId
        view?.displayRefreshing()

        certificatesAPI?.retrieve(userId: userId, success: {
            [weak self]
            meta, newCertificates in

            self?.certificates = newCertificates
            self?.page = 1

            self?.loadCoursesForCertificates(certificates: newCertificates, completion: {
                [weak self] in
                guard let s = self else {
                    return
                }
                s.view?.setCertificates(certificates: s.certificates.flatMap({
                    [weak self] in
                    return self?.certificateViewData(fromCertificate: $0)
                }), hasNextPage: meta.hasNext)
                s.view?.displayEmpty()
                CoreDataHelper.instance.save()
            })
        }, error: {
            [weak self]
            _ in
            self?.view?.displayError()
        })
    }

    private func loadCoursesForCertificates(certificates: [Certificate], completion: @escaping () -> Void) {
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
            _ in
            completion()
        })
    }

    private func certificateViewData(fromCertificate certificate: Certificate) -> CertificateViewData {

        var courseImageURL: URL? = nil
        if let courseImageURLString = certificate.course?.coverURLString {
            courseImageURL = URL(string: courseImageURLString)
        }

        var certificateURL: URL? = nil
        if let certificateURLString = certificate.urlString {
            certificateURL = URL(string: certificateURLString)
        }

        let certificateDescriptionBeginning = certificate.type == .distinction ? "\(NSLocalizedString("CertificateWithDistinction", comment: ""))" : "\(NSLocalizedString("Certificate", comment: ""))"

        let certificateDescriptionString = "\(certificateDescriptionBeginning) \(NSLocalizedString("CertificateDescriptionBody", comment: "")) \(certificate.course?.title ?? "")"

        return CertificateViewData(courseName: certificate.course?.title, courseImageURL: courseImageURL, grade: certificate.grade, certificateURL: certificateURL, certificateDescription: certificateDescriptionString)
    }

    fileprivate var isGettingNextPage: Bool = false

    func getNextPage() -> Bool {
        guard let userId = AuthInfo.shared.userId else {
            certificates = []
            view?.displayAnonymous()
            return false
        }

        if isGettingNextPage {
            return false
        }

        isGettingNextPage = true

        certificatesAPI?.retrieve(userId: userId, page: page + 1, success: {
            [weak self]
            meta, newCertificates in

            self?.page += 1
            self?.certificates += newCertificates

            self?.loadCoursesForCertificates(certificates: newCertificates, completion: {
                [weak self] in
                guard let s = self else {
                    self?.isGettingNextPage = false
                    return
                }
                s.view?.setCertificates(certificates: s.certificates.flatMap({
                    [weak self] in
                    return self?.certificateViewData(fromCertificate: $0)
                }), hasNextPage: meta.hasNext)
                CoreDataHelper.instance.save()
                self?.isGettingNextPage = false
            })
        }, error: {
            [weak self]
            _ in
            self?.view?.displayLoadNextPageError()
            self?.isGettingNextPage = false
        })

        return true
    }

}
