import MessageUI
import SVProgressHUD
import UIKit

final class ContactSupportController: NSObject {
    private let subject: String

    private weak var presentationController: UIViewController?
    private let userAccountService: UserAccountServiceProtocol

    init(
        subject: String = NSLocalizedString("ContactSupportSubject", comment: ""),
        presentationController: UIViewController,
        userAccountService: UserAccountServiceProtocol = UserAccountService()
    ) {
        self.subject = subject
        self.presentationController = presentationController
        self.userAccountService = userAccountService
    }

    func contactSupport() {
        guard MFMailComposeViewController.canSendMail() else {
            return self.presentNotAbleSendMailAlert()
        }

        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self

        mailComposeViewController.setToRecipients(["support@stepik.org"])
        mailComposeViewController.setSubject(self.subject)
        mailComposeViewController.setMessageBody(self.makeMessageBody(), isHTML: false)

        self.presentationController?.present(mailComposeViewController, animated: true)
    }

    private func makeMessageBody() -> String {
        let appVersion: String = {
            guard let versionNumber = Bundle.main.versionNumber else {
                return NSLocalizedString("AppVersionUnknownTitle", comment: "")
            }

            let buildNumber = Bundle.main.buildNumber ?? "0"

            return "\(versionNumber) (\(buildNumber))"
        }()

        let userID = "\(self.userAccountService.currentUser?.id ??? "null")"

        return String(
            format: NSLocalizedString("ContactSupportMessageBody", comment: ""),
            arguments: [appVersion, userID]
        )
    }

    private func presentNotAbleSendMailAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("NotAbleSendEmailAlertTitle", comment: ""),
            message: NSLocalizedString("NotAbleSendEmailAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.presentationController?.present(alert, animated: true)
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
