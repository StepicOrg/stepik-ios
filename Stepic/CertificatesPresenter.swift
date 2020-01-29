//
//  CertificatesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class CertificatesPresenter {
    weak var view: CertificatesView?

    private let userID: User.IdType
    private let certificatesAPI: CertificatesAPI
    private let coursesAPI: CoursesAPI
    private let presentationContainer: CertificatesPresentationContainer

    private var certificates: [Certificate] = [] {
        didSet {
            self.updatePersistentPresentationData()
        }
    }

    private var page = 1
    private var isGettingNextPage = false

    init(
        userID: User.IdType,
        certificatesAPI: CertificatesAPI,
        coursesAPI: CoursesAPI,
        presentationContainer: CertificatesPresentationContainer,
        view: CertificatesView?
    ) {
        self.userID = userID
        self.certificatesAPI = certificatesAPI
        self.coursesAPI = coursesAPI
        self.presentationContainer = presentationContainer
        self.view = view
    }

    func getCachedCertificates() {
        let localIds = self.presentationContainer.certificatesIds

        let localCertificates = Certificate.fetch(localIds, user: self.userID).sorted(by: {
            guard let index1 = localIds.firstIndex(of: $0.id),
                  let index2 = localIds.firstIndex(of: $1.id) else {
                return false
            }
            return index1 < index2
        }).compactMap { [weak self] in
            self?.makeViewData(from: $0)
        }

        self.view?.setCertificates(certificates: localCertificates, hasNextPage: false)
    }

    private func updatePersistentPresentationData() {
        self.presentationContainer.certificatesIds = certificates.map { $0.id }
    }

    func refreshCertificates() {
        view?.displayRefreshing()

        self.certificatesAPI.retrieve(userId: self.userID, success: { [weak self] meta, newCertificates in
            self?.certificates = newCertificates
            self?.page = 1

            self?.loadCoursesForCertificates(certificates: newCertificates, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.view?.setCertificates(certificates: strongSelf.certificates.compactMap({ [weak self] in
                    self?.makeViewData(from: $0)
                }), hasNextPage: meta.hasNext)
                strongSelf.view?.displayEmpty()
                CoreDataHelper.shared.save()
            })
        }, error: { [weak self] _ in
            self?.view?.displayError()
        })
    }

    private func loadCoursesForCertificates(certificates: [Certificate], completion: @escaping () -> Void) {
        func matchCoursesToCertificates(courses: [Course]) {
            for certificate in certificates {
                if let filtered = courses.filter({ $0.id == certificate.courseId }).first {
                    certificate.course = filtered
                }
            }
        }

        let courseIds = certificates.map { $0.courseId }

        let localCourses = Course.getCourses(courseIds)
        matchCoursesToCertificates(courses: localCourses)

        self.coursesAPI.retrieve(ids: courseIds, existing: localCourses, refreshMode: .update, success: { courses in
            matchCoursesToCertificates(courses: courses)
            completion()
        }, error: { _ in
            completion()
        })
    }

    private func makeViewData(from certificate: Certificate) -> CertificateViewData {
        var courseImageURL: URL?
        if let courseImageURLString = certificate.course?.coverURLString {
            courseImageURL = URL(string: courseImageURLString)
        }

        var certificateURL: URL?
        if let certificateURLString = certificate.urlString {
            certificateURL = URL(string: certificateURLString)
        }

        let certificateDescriptionBeginning = certificate.type == .distinction
            ? "\(NSLocalizedString("CertificateWithDistinction", comment: ""))"
            : "\(NSLocalizedString("Certificate", comment: ""))"

        let certificateDescriptionString = "\(certificateDescriptionBeginning) \(NSLocalizedString("CertificateDescriptionBody", comment: "")) \(certificate.course?.title ?? "")"

        return CertificateViewData(
            courseName: certificate.course?.title,
            courseImageURL: courseImageURL,
            grade: certificate.grade,
            certificateURL: certificateURL,
            certificateDescription: certificateDescriptionString
        )
    }

    func getNextPage() -> Bool {
        if isGettingNextPage {
            return false
        }

        isGettingNextPage = true

        self.certificatesAPI.retrieve(userId: self.userID, page: page + 1, success: {
            [weak self] meta, newCertificates in
            self?.page += 1
            self?.certificates += newCertificates

            self?.loadCoursesForCertificates(certificates: newCertificates, completion: { [weak self] in
                guard let strongSelf = self else {
                    self?.isGettingNextPage = false
                    return
                }

                strongSelf.view?.setCertificates(certificates: strongSelf.certificates.compactMap({ [weak self] in
                    self?.makeViewData(from: $0)
                }), hasNextPage: meta.hasNext)
                CoreDataHelper.shared.save()
                self?.isGettingNextPage = false
            })
        }, error: { [weak self] _ in
            self?.view?.displayLoadNextPageError()
            self?.isGettingNextPage = false
        })

        return true
    }
}
