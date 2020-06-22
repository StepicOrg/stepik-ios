import PromiseKit
import UIKit

protocol IAPServiceDelegate: AnyObject {
    func iapService(_ service: IAPServiceProtocol, didPurchaseCourse courseID: Course.IdType)
    func iapService(
        _ service: IAPServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    )
}

final class DefaultIAPServiceDelegate: IAPServiceDelegate {
    private let sourcelessRouter = SourcelessRouter()
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService()

    func iapService(_ service: IAPServiceProtocol, didPurchaseCourse courseID: Course.IdType) {
        DispatchQueue.main.async {
            self.handle(courseID: courseID, error: nil)
        }
    }

    func iapService(
        _ service: IAPServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Error
    ) {
        DispatchQueue.main.async {
            self.handle(courseID: courseID, error: error)
        }
    }

    private func handle(courseID: Course.IdType, error: Error?) {
        guard let rootViewController = self.sourcelessRouter.window?.rootViewController else {
            return
        }

        self.coursesPersistenceService.fetch(id: courseID).done { course in
            let isSuccess = error == nil
            let courseTitle = course?.title ?? "\(courseID)"

            let title = isSuccess
                ? NSLocalizedString("IAPPurchaseSucceededTitle", comment: "")
                : NSLocalizedString("IAPPurchaseFailedTitle", comment: "")

            let message = isSuccess
                ? String(
                    format: NSLocalizedString("IAPPurchaseSucceededMessage", comment: ""),
                    arguments: [courseTitle]
                  )
                : String(
                    format: NSLocalizedString("IAPPurchaseFailedMessage", comment: ""),
                    arguments: [courseTitle, error.require().localizedDescription]
                  )

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))

            rootViewController.present(alert, animated: true, completion: nil)
        }.cauterize()
    }
}
