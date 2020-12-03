import Foundation
import PromiseKit
import StoreKit

protocol IAPReceiptValidationServiceProtocol: AnyObject {
    func validateCoursePayment(courseID: Course.IdType, price: Double, currencyCode: String?) -> Promise<CoursePayment>
}

final class IAPReceiptValidationService: IAPReceiptValidationServiceProtocol {
    private let coursePaymentsNetworkService: CoursePaymentsNetworkServiceProtocol

    init(coursePaymentsNetworkService: CoursePaymentsNetworkServiceProtocol) {
        self.coursePaymentsNetworkService = coursePaymentsNetworkService
    }

    func validateCoursePayment(
        courseID: Course.IdType,
        price: Double,
        currencyCode: String?
    ) -> Promise<CoursePayment> {
        guard let receiptString = self.getAppStoreReceiptBase64EncodedString() else {
            return Promise(error: Error.noAppStoreReceiptPresent)
        }

        guard let currencyCode = currencyCode,
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return Promise(error: Error.invalidPaymentData)
        }

        let paymentData = CoursePayment.DataFactory.generateDataForAppleProvider(
            receiptData: receiptString,
            bundleID: bundleIdentifier,
            amount: price,
            currency: currencyCode
        )
        let payment = CoursePayment(courseID: courseID, data: paymentData)

        return Promise { seal in
            self.coursePaymentsNetworkService.create(coursePayment: payment).done { coursePayment in
                if coursePayment.status == .success {
                    print("IAPReceiptValidationService :: successfully verified course payment for course: \(courseID)")
                    seal.fulfill(coursePayment)
                } else {
                    print("IAPReceiptValidationService :: failed verify course payment with status: \(coursePayment.statusStringValue)")
                    seal.reject(Error.invalidFinalStatus)
                }
            }.catch { error in
                print("IAPReceiptValidationService :: failed create course payment with error: \(error)")
                seal.reject(Error.requestFailed)
            }
        }
    }

    private func getAppStoreReceiptBase64EncodedString() -> String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }

        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            let receiptString = receiptData.base64EncodedString(options: [])
            return receiptString
        } catch {
            print("IAPReceiptValidationService :: couldn't read receipt data with error: \(error)")
            return nil
        }
    }

    enum Error: Swift.Error {
        case noAppStoreReceiptPresent
        case invalidPaymentData
        case invalidFinalStatus
        case requestFailed
    }
}

fileprivate final class IAPReceiptRefreshRequest: NSObject, SKRequestDelegate {
    typealias CompletionHandler = (ResultType) -> Void

    private let request: SKReceiptRefreshRequest
    private let completionHandler: CompletionHandler?

    init(receiptProperties: [String: Any]?, completionHandler: CompletionHandler?) {
        self.request = SKReceiptRefreshRequest(receiptProperties: receiptProperties)
        self.completionHandler = completionHandler

        super.init()

        self.request.delegate = self
    }

    deinit {
        self.request.delegate = nil
    }

    // MARK: Public API

    func start() {
        self.request.start()
    }

    func cancel() {
        self.request.cancel()
    }

    // MARK: SKRequestDelegate

    func requestDidFinish(_ request: SKRequest) {
        #if DEBUG
        print("IAPReceiptRefreshRequest :: requestDidFinish")

        if let receiptRefreshRequest = request as? SKReceiptRefreshRequest {
            let receiptProperties = receiptRefreshRequest.receiptProperties ?? [:]

            print("IAPReceiptRefreshRequest :: printing receipt properties")

            for (key, value) in receiptProperties {
                print("\(key): \(value)")
            }
        }
        #endif

        DispatchQueue.main.async {
            self.completionHandler?(.success)
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        #if DEBUG
        print("IAPReceiptRefreshRequest :: request did fail with error = \(error)")
        #endif

        DispatchQueue.main.async {
            self.completionHandler?(.error(error))
        }
    }

    enum ResultType {
        case success
        case error(Error)
    }
}
