import Foundation
import StepikModel

protocol CertificateDetailOutputProtocol: AnyObject {
    func handleCertificateDetailDidChangeRecipientName(certificate: StepikModel.Certificate)
}
