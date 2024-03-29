import UIKit

protocol CertificateDetailPresenterProtocol {
    func presentCertificate(response: CertificateDetail.CertificateLoad.Response)
    func presentCertificateShare(response: CertificateDetail.CertificateSharePresentation.Response)
    func presentCertificatePDF(response: CertificateDetail.CertificatePDFPresentation.Response)
    func presentCourse(response: CertificateDetail.CoursePresentation.Response)
    func presentRecipient(response: CertificateDetail.RecipientPresentation.Response)
    func presentPromptForChangeCertificateNameInput(
        response: CertificateDetail.PromptForChangeCertificateNameInput.Response
    )
    func presentUpdateCertificateRecipientNameResult(
        response: CertificateDetail.UpdateCertificateRecipientName.Response
    )
}

final class CertificateDetailPresenter: CertificateDetailPresenterProtocol {
    weak var viewController: CertificateDetailViewControllerProtocol?

    private let stepikURLFactory: StepikURLFactory

    init(stepikURLFactory: StepikURLFactory) {
        self.stepikURLFactory = stepikURLFactory
    }

    func presentCertificate(response: CertificateDetail.CertificateLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(certificate: data.certificate, currentUserID: data.currentUserID)
            self.viewController?.displayCertificate(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCertificate(viewModel: .init(state: .error))
        }
    }

    func presentCertificateShare(response: CertificateDetail.CertificateSharePresentation.Response) {
        guard let shareURL = self.stepikURLFactory.makeCertificate(id: response.certificateID) else {
            return
        }

        self.viewController?.displayCertificateShare(viewModel: .init(url: shareURL))
    }

    func presentCertificatePDF(response: CertificateDetail.CertificatePDFPresentation.Response) {
        self.viewController?.displayCertificatePDF(viewModel: .init(url: response.url))
    }

    func presentCourse(response: CertificateDetail.CoursePresentation.Response) {
        self.viewController?.displayCourse(
            viewModel: .init(courseID: response.courseID, certificateID: response.certificateID)
        )
    }

    func presentRecipient(response: CertificateDetail.RecipientPresentation.Response) {
        self.viewController?.displayRecipient(viewModel: .init(userID: response.userID))
    }

    func presentPromptForChangeCertificateNameInput(
        response: CertificateDetail.PromptForChangeCertificateNameInput.Response
    ) {
        self.viewController?.displayPromptForChangeCertificateNameInput(
            viewModel: .init(
                editsCount: response.certificate.editsCount,
                allowedEditsCount: response.certificate.allowedEditsCount,
                savedFullName: response.certificate.savedFullName,
                predefinedNewFullName: response.predefinedNewFullName
            )
        )
    }

    func presentUpdateCertificateRecipientNameResult(
        response: CertificateDetail.UpdateCertificateRecipientName.Response
    ) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(certificate: data.certificate, currentUserID: data.currentUserID)
            self.viewController?.displayUpdateCertificateRecipientNameResult(
                viewModel: .init(state: .success(data: viewModel))
            )
        case .failure:
            self.viewController?.displayUpdateCertificateRecipientNameResult(
                viewModel: .init(state: .failure(predefinedNewFullName: response.predefinedNewFullName))
            )
        }
    }

    // MARK: Private API

    private func makeViewModel(certificate: Certificate, currentUserID: User.IdType?) -> CertificateDetailViewModel {
        let formattedIssueDate: String? = {
            if let issueDate = certificate.issueDate {
                return FormatterHelper.dateStringWithFullMonthAndYearCommaTime(issueDate)
            }
            return nil
        }()

        let formattedUserRank: String? = {
            guard let leaderboardSize = certificate.leaderboardSize,
                  let userRankMax = certificate.userRankMax else {
                return nil
            }

            let rank = leaderboardSize - userRankMax
            let formattedRankNumber = FormatterHelper.numberWithThousandSeparator(rank) ?? "\(rank)"

            let pluralizedCountString = StringHelper.pluralize(
                number: rank,
                forms: [
                    NSLocalizedString("CertificateDetailUserRankText1", comment: ""),
                    NSLocalizedString("CertificateDetailUserRankText234", comment: ""),
                    NSLocalizedString("CertificateDetailUserRankText567890", comment: "")
                ]
            )

            return String(format: pluralizedCountString, arguments: [formattedRankNumber])
        }()

        let previewURL: URL? = {
            if let previewURLString = certificate.previewURLString {
                return URL(string: previewURLString)
            }
            return nil
        }()

        let shareURL = self.stepikURLFactory.makeCertificate(id: certificate.id)

        return CertificateDetailViewModel(
            formattedIssueDate: formattedIssueDate,
            formattedGrade: "\(certificate.grade)%",
            courseTitle: certificate.courseTitle,
            userFullName: certificate.savedFullName,
            formattedUserRank: formattedUserRank,
            previewURL: previewURL,
            shareURL: shareURL,
            isEditAvailable: certificate.userID == currentUserID,
            isEditAllowed: certificate.isEditAllowed,
            isWithDistinction: certificate.type == .distinction
        )
    }
}
