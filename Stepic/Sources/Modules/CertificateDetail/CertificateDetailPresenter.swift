import UIKit

protocol CertificateDetailPresenterProtocol {
    func presentCertificate(response: CertificateDetail.CertificateLoad.Response)
}

final class CertificateDetailPresenter: CertificateDetailPresenterProtocol {
    weak var viewController: CertificateDetailViewControllerProtocol?

    func presentCertificate(response: CertificateDetail.CertificateLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(certificate: data.certificate, currentUserID: data.currentUserID)
            self.viewController?.displayCertificate(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCertificate(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(certificate: Certificate, currentUserID: User.IdType?) -> CertificateDetailViewModel {
        let formattedIssueDate: String? = {
            if let issueDate = certificate.issueDate {
                return FormatterHelper.dateStringWithFullMonthAndYear(issueDate)
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

        let isEditAvailable = certificate.isEditAllowed && certificate.userID == currentUserID

        return CertificateDetailViewModel(
            formattedIssueDate: formattedIssueDate,
            formattedGrade: "\(certificate.grade)%",
            courseTitle: certificate.courseTitle,
            userFullName: certificate.savedFullName,
            formattedUserRank: formattedUserRank,
            previewURL: previewURL,
            isEditAvailable: isEditAvailable,
            isWithDistinction: certificate.type == .distinction
        )
    }
}
