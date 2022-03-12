import Foundation

protocol CertificatesView: AnyObject {
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool)
    func updateCertificate(certificate: CertificateViewData, at index: Int)

    func displayError()
    func displayEmpty()
    func displayRefreshing()
    func displayLoadNextPageError()
}
