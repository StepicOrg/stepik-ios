import MessageUI
import SVProgressHUD
import UIKit

final class ContactSupportController: NSObject {
    private weak var presentationController: UIViewController?

    init(presentationController: UIViewController) {
        self.presentationController = presentationController
    }

    func contactSupport() {
        guard MFMailComposeViewController.canSendMail() else {
            return self.presentSendMailErrorAlert()
        }

        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self

        // TODO: Set subject, message body
        mailComposeViewController.setToRecipients(["support@stepik.org"])
        mailComposeViewController.setSubject(
            String(
                format: NSLocalizedString("FeedbackAbout", comment: ""),
                Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Stepik"
            )
        )
        mailComposeViewController.setMessageBody("", isHTML: false)

        self.presentationController?.present(mailComposeViewController, animated: true)
    }

    private func presentSendMailErrorAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("SendMailErrorAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.presentationController?.present(alert, animated: true)
    }
}

extension ContactSupportController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        if result == .failed || error != nil {
            self.presentSendMailErrorAlert()
        } else {
            self.presentationController?.dismiss(
                animated: true,
                completion: {
                    if result == .sent {
                        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SendMailSuccessMessage", comment: ""))
                    }
                }
            )
        }
    }
}
