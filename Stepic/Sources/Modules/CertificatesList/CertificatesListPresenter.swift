import UIKit

protocol CertificatesListPresenterProtocol {
    func presentCertificates(response: CertificatesList.CertificatesLoad.Response)
    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response)
    func presentCertificateDetail(response: CertificatesList.CertificateDetailPresentation.Response)
}

final class CertificatesListPresenter: CertificatesListPresenterProtocol {
    weak var viewController: CertificatesListViewControllerProtocol?

    func presentCertificates(response: CertificatesList.CertificatesLoad.Response) {
        switch response.result {
        case .success(let data):
            let resultData = CertificatesList.CertificatesResult(
                certificates: data.certificates.map(self.makeViewModel(certificate:)),
                hasNextPage: data.hasNextPage
            )

            if resultData.certificates.isEmpty {
                self.viewController?.displayCertificates(
                    viewModel: .init(state: .empty(isCurrentUser: data.isCurrentUser))
                )
            } else {
                self.viewController?.displayCertificates(viewModel: .init(state: .result(data: resultData)))
            }
        case .failure:
            self.viewController?.displayCertificates(viewModel: .init(state: .error))
        }
    }

    func presentNextCertificates(response: CertificatesList.NextCertificatesLoad.Response) {
        switch response.result {
        case .success(let data):
            let data = CertificatesList.CertificatesResult(
                certificates: data.certificates.map(self.makeViewModel(certificate:)),
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayNextCertificates(viewModel: .init(state: .result(data: data)))
        case .failure:
            self.viewController?.displayNextCertificates(viewModel: .init(state: .error))
        }
    }

    func presentCertificateDetail(response: CertificatesList.CertificateDetailPresentation.Response) {
        self.viewController?.displayCertificateDetail(viewModel: .init(certificateID: response.certificateID))
    }

    // MARK: Private API

    private func makeViewModel(certificate: Certificate) -> CertificatesListItemViewModel {
        let courseCoverURL: URL? = {
            if let coverURLString = certificate.course?.coverURLString {
                return URL(string: coverURLString)
            }
            return nil
        }()

        let formattedIssueDate: String? = {
            if let issueDate = certificate.issueDate {
                return FormatterHelper.dateToRelativeString(issueDate)
            }
            return nil
        }()

        let formattedGrade = String(
            format: NSLocalizedString("CertificatesListGradeText", comment: ""),
            arguments: ["\(certificate.grade)"]
        )

        return CertificatesListItemViewModel(
            uniqueIdentifier: "\(certificate.id)",
            courseTitle: certificate.courseTitle,
            courseCoverURL: courseCoverURL,
            formattedIssueDate: formattedIssueDate,
            formattedGrade: formattedGrade,
            certificateType: certificate.type
        )
    }
}
