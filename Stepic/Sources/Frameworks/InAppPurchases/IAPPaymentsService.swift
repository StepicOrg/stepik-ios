import Foundation
import PromiseKit
import StoreKit

protocol IAPPaymentsServiceDelegate: AnyObject {
    func iapPaymentsService(_ service: IAPPaymentsServiceProtocol, didPurchaseCourse courseID: Course.IdType)
    func iapPaymentsService(
        _ service: IAPPaymentsServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    )
}

// MARK: - IAPPaymentsService -

protocol IAPPaymentsServiceProtocol: AnyObject {
    var delegate: IAPPaymentsServiceDelegate? { get set }

    func startObserving()
    func stopObserving()

    func canMakePayments() -> Bool

    func buy(courseID: Course.IdType, product: SKProduct)
    func retryValidateReceipt(courseID: Course.IdType, productIdentifier: IAPProductIdentifier)
}

final class IAPPaymentsService: NSObject, IAPPaymentsServiceProtocol {
    weak var delegate: IAPPaymentsServiceDelegate?

    private let paymentQueue: SKPaymentQueue
    private let paymentsCache: IAPPaymentsCacheProtocol
    private let receiptValidationService: IAPReceiptValidationServiceProtocol

    private let userAccountService: UserAccountServiceProtocol

    init(
        paymentQueue: SKPaymentQueue = SKPaymentQueue.default(),
        paymentsCache: IAPPaymentsCacheProtocol = IAPPaymentsCache(userAccountService: UserAccountService()),
        receiptValidationService: IAPReceiptValidationServiceProtocol = IAPReceiptValidationService(
            coursePaymentsNetworkService: CoursePaymentsNetworkService(
                coursePaymentsAPI: CoursePaymentsAPI()
            )
        ),
        userAccountService: UserAccountServiceProtocol = UserAccountService()
    ) {
        self.paymentQueue = paymentQueue
        self.paymentsCache = paymentsCache
        self.receiptValidationService = receiptValidationService
        self.userAccountService = userAccountService
        super.init()
    }

    deinit {
        self.stopObserving()
    }

    func startObserving() {
        self.paymentQueue.add(self)
    }

    func stopObserving() {
        self.paymentQueue.remove(self)
    }

    func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    func buy(courseID: Course.IdType, product: SKProduct) {
        if self.canMakePayments() {
            self.paymentsCache.insertCoursePayment(courseID: courseID, product: product)
            self.paymentQueue.add(SKPayment(product: product))
        } else {
            self.delegate?.iapPaymentsService(self, didFailPurchaseCourse: courseID, withError: Error.paymentNotAllowed)
        }
    }

    func retryValidateReceipt(courseID: Course.IdType, productIdentifier: IAPProductIdentifier) {
        guard let transaction = self.paymentQueue.transactions.first(
            where: { $0.payment.productIdentifier == productIdentifier }
        ), transaction.transactionState == .purchased else {
            return
        }

        guard let payload = self.paymentsCache.getCoursePayment(for: transaction),
              payload.courseID == courseID else {
            return
        }

        self.validateReceipt(transaction: transaction, payload: payload, forceRefreshReceipt: true)
    }

    enum Error: Swift.Error {
        case paymentNotAllowed
        case paymentCancelled
        case paymentFailed
        case paymentUserChanged
        case paymentReceiptValidationFailed
    }
}

// MARK: - IAPPaymentsService: SKPaymentTransactionObserver -

extension IAPPaymentsService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            self.processTransaction(transaction)
        }
    }

    // MARK: Private Helpers

    private func processTransaction(_ transaction: SKPaymentTransaction) {
        guard let payload = self.paymentsCache.getCoursePayment(for: transaction) else {
            return print("IAPPaymentsService :: payment failed missing payload data")
        }

        switch transaction.transactionState {
        case .purchased:
            guard let currentUserID = self.userAccountService.currentUser?.id,
                  currentUserID == payload.userID else {
                self.delegate?.iapPaymentsService(
                    self,
                    didFailPurchaseCourse: payload.courseID,
                    withError: Error.paymentUserChanged
                )
                return print("IAPPaymentsService :: payment failed invalid user")
            }

            self.validateReceipt(transaction: transaction, payload: payload)
        case .failed:
            if let skError = transaction.error as? SKError {
                if skError.code != .paymentCancelled {
                    self.delegate?.iapPaymentsService(
                        self,
                        didFailPurchaseCourse: payload.courseID,
                        withError: Error.paymentFailed
                    )
                } else {
                    self.delegate?.iapPaymentsService(
                        self,
                        didFailPurchaseCourse: payload.courseID,
                        withError: Error.paymentCancelled
                    )
                }
                print("IAPPaymentsService :: payment failed with error: \(skError)")
            } else {
                print("IAPPaymentsService :: payment failed with unknown error")
                self.delegate?.iapPaymentsService(
                    self,
                    didFailPurchaseCourse: payload.courseID,
                    withError: Error.paymentFailed
                )
            }

            self.paymentsCache.removeCoursePayment(for: transaction)
            self.paymentQueue.finishTransaction(transaction)
        case .purchasing, .deferred, .restored:
            break
        @unknown default:
            break
        }
    }

    private func validateReceipt(
        transaction: SKPaymentTransaction,
        payload: CoursePaymentPayload,
        forceRefreshReceipt: Bool = false
    ) {
        self.receiptValidationService.validateCoursePayment(
            courseID: payload.courseID,
            price: payload.price,
            currencyCode: payload.currencyCode,
            forceRefreshReceipt: forceRefreshReceipt
        ).done { _ in
            self.delegate?.iapPaymentsService(self, didPurchaseCourse: payload.courseID)

            self.paymentsCache.removeCoursePayment(for: transaction)
            self.paymentQueue.finishTransaction(transaction)
        }.catch { error in
            print("IAPPaymentsService :: failed validate payment with error: \(error)")
            self.delegate?.iapPaymentsService(
                self,
                didFailPurchaseCourse: payload.courseID,
                withError: Error.paymentReceiptValidationFailed
            )
        }
    }
}
