import Foundation
import PromiseKit

protocol CertificateDetailInteractorProtocol {
    func doCertificateLoad(request: CertificateDetail.CertificateLoad.Request)
    func doCertificatePDFPresentation(request: CertificateDetail.CertificatePDFPresentation.Request)
    func doCoursePresentation(request: CertificateDetail.CoursePresentation.Request)
    func doRecipientPresentation(request: CertificateDetail.RecipientPresentation.Request)
}

final class CertificateDetailInteractor: CertificateDetailInteractorProtocol {
    weak var moduleOutput: CertificateDetailOutputProtocol?

    private let presenter: CertificateDetailPresenterProtocol
    private let provider: CertificateDetailProviderProtocol

    private let userAccountService: UserAccountServiceProtocol

    private let analytics: Analytics

    private let certificateID: Certificate.IdType

    private var currentCertificate: Certificate?

    init(
        certificateID: Certificate.IdType,
        presenter: CertificateDetailPresenterProtocol,
        provider: CertificateDetailProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        analytics: Analytics
    ) {
        self.certificateID = certificateID
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.analytics = analytics
    }

    func doCertificateLoad(request: CertificateDetail.CertificateLoad.Request) {
        self.provider.fetchCertificate(id: self.certificateID).compactMap { $0 }.done { certificate in
            self.currentCertificate = certificate

            let data = CertificateDetail.CertificateLoad.Data(
                certificate: certificate,
                currentUserID: self.userAccountService.currentUserID
            )

            self.presenter.presentCertificate(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentCertificate(response: .init(result: .failure(error)))
        }
    }

    func doCertificatePDFPresentation(request: CertificateDetail.CertificatePDFPresentation.Request) {
        guard let certificate = self.currentCertificate,
              let urlString = certificate.urlString,
              let url = URL(string: urlString) else {
            return
        }

        self.analytics.send(.certificateOpened(grade: certificate.grade, courseName: certificate.courseTitle))
        self.analytics.send(
            .certificatePDFClicked(
                certificateID: certificate.id,
                courseID: certificate.courseID,
                userID: certificate.userID,
                certificateUserState: self.userAccountService.currentUserID == certificate.userID ? .`self` : .other
            )
        )

        self.presenter.presentCertificatePDF(response: .init(url: url))
    }

    func doCoursePresentation(request: CertificateDetail.CoursePresentation.Request) {
        guard let certificate = self.currentCertificate else {
            return
        }

        self.presenter.presentCourse(response: .init(courseID: certificate.courseID, certificateID: certificate.id))
    }

    func doRecipientPresentation(request: CertificateDetail.RecipientPresentation.Request) {
        guard let certificate = self.currentCertificate else {
            return
        }

        self.presenter.presentRecipient(response: .init(userID: certificate.userID))
    }
}

extension CertificateDetailInteractor: CertificateDetailInputProtocol {}
