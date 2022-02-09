import Foundation
import PromiseKit

final class CertificatesPresenter {
    weak var view: CertificatesView?

    private let userID: User.IdType

    private let certificatesNetworkService: CertificatesNetworkServiceProtocol
    private let certificatesPersistenceService: CertificatesPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let userAccountService: UserAccountServiceProtocol

    private var currentCertificates = [Certificate]()
    private var currentPage = 1
    private var isFetchingNextPage = false

    init(
        userID: User.IdType,
        certificatesNetworkService: CertificatesNetworkServiceProtocol,
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol,
        view: CertificatesView?
    ) {
        self.userID = userID
        self.certificatesNetworkService = certificatesNetworkService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.userAccountService = userAccountService
        self.view = view
    }

    // MARK: Public API

    func getCachedCertificates() {
        self.certificatesPersistenceService.fetch(userID: self.userID).done { cachedCertificates in
            if cachedCertificates.isEmpty {
                return
            }

            let viewData = cachedCertificates.map(self.makeViewData(from:))
            self.view?.setCertificates(certificates: viewData, hasNextPage: false)
        }
    }

    func refreshCertificates() {
        self.view?.displayRefreshing()

        self.certificatesNetworkService.fetch(
            userID: self.userID
        ).then { fetchResult -> Promise<([Certificate], Meta)> in
            self.loadCoursesForCertificates(fetchResult.0).map { fetchResult }
        }.done { certificates, meta in
            self.currentCertificates = certificates
            self.currentPage = 1

            let viewData = self.currentCertificates.map(self.makeViewData(from:))
            self.view?.setCertificates(certificates: viewData, hasNextPage: meta.hasNext)
        }.catch { _ in
            self.view?.displayError()
        }
    }

    func getNextPage() -> Bool {
        if self.isFetchingNextPage {
            return false
        }

        self.isFetchingNextPage = true
        let nextPageIndex = self.currentPage + 1

        self.certificatesNetworkService.fetch(
            userID: self.userID,
            page: nextPageIndex
        ).then { fetchResult -> Promise<([Certificate], Meta)> in
            self.loadCoursesForCertificates(fetchResult.0).map { fetchResult }
        }.done { certificates, meta in
            self.currentPage = nextPageIndex
            self.currentCertificates += certificates

            let viewData = self.currentCertificates.map(self.makeViewData(from:))
            self.view?.setCertificates(certificates: viewData, hasNextPage: meta.hasNext)
        }.ensure {
            self.isFetchingNextPage = false
        }.catch { _ in
            self.view?.displayLoadNextPageError()
        }

        return true
    }

    func updateCertificateName(
        viewDataUniqueIdentifier: UniqueIdentifierType,
        newFullName: String
    ) -> Promise<CertificateViewData> {
        guard let certificateEntity = self.currentCertificates.first(
            where: { "\($0.id)" == viewDataUniqueIdentifier }
        ) else {
            return Promise(error: Error.updateCertificateNameFailed)
        }

        let oldFullName = certificateEntity.savedFullName
        certificateEntity.savedFullName = newFullName

        return Promise { seal in
            self.certificatesNetworkService.update(certificate: certificateEntity).done { updatedCertificate in
                let viewData = self.makeViewData(from: updatedCertificate)
                seal.fulfill(viewData)
            }.catch { _ in
                certificateEntity.savedFullName = oldFullName
                seal.reject(Error.updateCertificateNameFailed)
            }.finally {
                CoreDataHelper.shared.save()
            }
        }
    }

    // MARK: Private API

    private func loadCoursesForCertificates(_ certificates: [Certificate]) -> Promise<Void> {
        self.coursesNetworkService.fetch(ids: certificates.map(\.courseID)).done { courses in
            if certificates.isEmpty || courses.isEmpty {
                return
            }

            let coursesMap = Dictionary(courses.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

            for certificate in certificates {
                certificate.course = coursesMap[certificate.courseID]
            }
        }
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

        let isEditAvailable = certificate.isEditAllowed && self.userID == self.userAccountService.currentUserID

        return CertificateViewData(
            uniqueIdentifier: "\(certificate.id)",
            courseName: certificate.course?.title,
            courseImageURL: courseImageURL,
            grade: certificate.grade,
            certificateURL: certificateURL,
            certificateDescription: certificateDescriptionString,
            isEditAvailable: isEditAvailable,
            editsCount: certificate.editsCount,
            allowedEditsCount: certificate.allowedEditsCount,
            savedFullName: certificate.savedFullName
        )
    }

    enum Error: Swift.Error {
        case updateCertificateNameFailed
    }
}
