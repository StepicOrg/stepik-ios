import Foundation
import Nuke
import PromiseKit
import StepikModel

protocol CertificateDetailInteractorProtocol {
    func doCertificateLoad(request: CertificateDetail.CertificateLoad.Request)
    func doCertificateSharePresentation(request: CertificateDetail.CertificateSharePresentation.Request)
    func doCertificatePDFPresentation(request: CertificateDetail.CertificatePDFPresentation.Request)
    func doCoursePresentation(request: CertificateDetail.CoursePresentation.Request)
    func doRecipientPresentation(request: CertificateDetail.RecipientPresentation.Request)
    func doPromptForChangeCertificateNameInput(request: CertificateDetail.PromptForChangeCertificateNameInput.Request)
    func doUpdateCertificateRecipientName(request: CertificateDetail.UpdateCertificateRecipientName.Request)
}

final class CertificateDetailInteractor: CertificateDetailInteractorProtocol {
    weak var moduleOutput: CertificateDetailOutputProtocol?

    private let presenter: CertificateDetailPresenterProtocol
    private let provider: CertificateDetailProviderProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let analytics: Analytics

    private let certificateID: Certificate.IdType

    private var currentCertificate: Certificate?
    private var shouldSendOpenedAnalyticsEvent = true

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

            let data = CertificateDetail.CertificateData(
                certificate: certificate,
                currentUserID: self.userAccountService.currentUserID
            )
            self.presenter.presentCertificate(response: .init(result: .success(data)))

            self.sendOpenedAnalyticsEventIfNeeded()
        }.catch { error in
            self.presenter.presentCertificate(response: .init(result: .failure(error)))
        }
    }

    func doCertificateSharePresentation(request: CertificateDetail.CertificateSharePresentation.Request) {
        guard let certificate = self.currentCertificate else {
            return
        }

        self.analytics.send(
            .certificateShareClicked(
                certificateID: certificate.id,
                courseID: certificate.courseID,
                userID: certificate.userID,
                certificateUserState: self.userAccountService.currentUserID == certificate.userID ? .`self` : .other
            )
        )

        self.presenter.presentCertificateShare(response: .init(certificateID: certificate.id))
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

    func doPromptForChangeCertificateNameInput(request: CertificateDetail.PromptForChangeCertificateNameInput.Request) {
        guard let certificate = self.currentCertificate,
              certificate.isEditAllowed else {
            return
        }

        self.analytics.send(
            .certificateChangeNameClicked(certificateID: certificate.id, courseID: certificate.courseID)
        )

        self.presenter.presentPromptForChangeCertificateNameInput(
            response: .init(
                certificate: certificate,
                predefinedNewFullName: request.predefinedNewFullName
            )
        )
    }

    func doUpdateCertificateRecipientName(request: CertificateDetail.UpdateCertificateRecipientName.Request) {
        guard let certificate = self.currentCertificate,
              certificate.isEditAllowed,
              !request.newFullName.isEmpty else {
            return self.presenter.presentUpdateCertificateRecipientNameResult(
                response: .init(
                    predefinedNewFullName: request.newFullName,
                    result: .failure(Error.updateCertificateNameFailed)
                )
            )
        }

        let oldFullName = certificate.savedFullName
        certificate.savedFullName = request.newFullName

        self.provider.update(certificate: certificate.plainObject).done { [weak self] updatedCertificate in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentCertificate = updatedCertificate
            strongSelf.removePreviewURLFromImageCache(previewURLString: updatedCertificate.previewURLString)

            let data = CertificateDetail.CertificateData(
                certificate: updatedCertificate,
                currentUserID: strongSelf.userAccountService.currentUserID
            )
            strongSelf.presenter.presentUpdateCertificateRecipientNameResult(response: .init(result: .success(data)))

            strongSelf.moduleOutput?.handleCertificateDetailDidChangeRecipientName(certificate: updatedCertificate)
        }.catch { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            certificate.savedFullName = oldFullName

            strongSelf.presenter.presentUpdateCertificateRecipientNameResult(
                response: .init(
                    predefinedNewFullName: request.newFullName,
                    result: .failure(Error.updateCertificateNameFailed)
                )
            )
        }.finally {
            CoreDataHelper.shared.save()
        }
    }

    // MARK: Private API

    private func removePreviewURLFromImageCache(previewURLString: String?) {
        guard let previewURLString = previewURLString,
              let previewURL = URL(string: previewURLString) else {
            return
        }

        let imageCache = ImageCache.shared
        let imageRequest = ImageRequest(url: previewURL)

        imageCache[imageRequest] = nil
    }

    private func sendOpenedAnalyticsEventIfNeeded() {
        guard self.shouldSendOpenedAnalyticsEvent,
              let certificate = self.currentCertificate else {
            return
        }

        self.shouldSendOpenedAnalyticsEvent = false

        self.analytics.send(
            .certificateScreenOpened(
                certificateID: certificate.id,
                courseID: certificate.courseID,
                userID: certificate.userID,
                certificateUserState: self.userAccountService.currentUserID == certificate.userID ? .`self` : .other
            )
        )
    }

    // MARK: Inner Types

    enum Error: Swift.Error {
        case updateCertificateNameFailed
    }
}
