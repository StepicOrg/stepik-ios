import UIKit

protocol NewProfileCertificatesPresenterProtocol {
    func presentCertificates(response: NewProfileCertificates.CertificatesLoad.Response)
    func presentCertificateDetail(response: NewProfileCertificates.CertificateDetailPresentation.Response)
}

final class NewProfileCertificatesPresenter: NewProfileCertificatesPresenterProtocol {
    weak var viewController: NewProfileCertificatesViewControllerProtocol?

    func presentCertificates(response: NewProfileCertificates.CertificatesLoad.Response) {
        switch response.result {
        case .success(let certificates):
            let viewModel = self.makeViewModel(certificates: certificates)
            self.viewController?.displayCertificates(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCertificates(viewModel: .init(state: .error))
        }
    }

    func presentCertificateDetail(response: NewProfileCertificates.CertificateDetailPresentation.Response) {
        self.viewController?.displayCertificateDetail(viewModel: .init(certificateID: response.certificateID))
    }

    private func makeViewModel(certificates: [Certificate]) -> NewProfileCertificatesViewModel {
        let certificates = certificates.compactMap { certificate -> NewProfileCertificatesCertificateViewModel? in
            guard let course = certificate.course else {
                return nil
            }

            var courseImageURL: URL?
            if let courseCoverURLString = certificate.course?.coverURLString {
                courseImageURL = URL(string: courseCoverURLString)
            }

            let certificateGrade = certificate.isWithScore ? certificate.grade : nil

            var certificateURL: URL?
            if let certificateURLString = certificate.urlString {
                certificateURL = URL(string: certificateURLString)
            }

            return .init(
                uniqueIdentifier: "\(certificate.id)",
                courseTitle: course.title,
                courseImageURL: courseImageURL,
                certificateGrade: certificateGrade,
                certificateURL: certificateURL,
                certificateType: certificate.type
            )
        }

        return NewProfileCertificatesViewModel(certificates: certificates)
    }
}
