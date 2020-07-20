import UIKit

protocol NewProfileCertificatesPresenterProtocol {
    func presentCertificates(response: NewProfileCertificates.CertificatesLoad.Response)
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

            return .init(
                courseTitle: course.title,
                courseImageURL: courseImageURL,
                certificateGrade: certificateGrade,
                certificateType: certificate.type
            )
        }

        return NewProfileCertificatesViewModel(certificates: certificates)
    }
}
