import Foundation

protocol CertificatesView: AnyObject {
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool)

    func displayError()
    func displayEmpty()
    func displayRefreshing()
    func displayLoadNextPageError()
}
