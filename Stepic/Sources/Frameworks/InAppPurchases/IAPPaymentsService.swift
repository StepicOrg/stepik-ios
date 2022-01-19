import Foundation
import PromiseKit
import StoreKit

protocol IAPPaymentsServiceDelegate: AnyObject {
    func iapPaymentsService(
        _ service: IAPPaymentsServiceProtocol,
        didReceiveTransactionState transactionState: IAPPaymentTransactionState,
        forCourse courseID: Course.IdType
    )
    func iapPaymentsService(
        _ service: IAPPaymentsServiceProtocol,
        didPurchaseCourse courseID: Course.IdType
    )
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

    func buy(courseID: Course.IdType, promoCode: String?, product: SKProduct)
    func retryValidateReceipt(courseID: Course.IdType, productIdentifier: IAPProductIdentifier)

    func finishAllTransactions() -> Int
}

final class IAPPaymentsService: NSObject, IAPPaymentsServiceProtocol {
    weak var delegate: IAPPaymentsServiceDelegate?

    private let paymentQueue: SKPaymentQueue
    private let paymentsCache: IAPPaymentsCacheProtocol
    private let receiptValidationService: IAPReceiptValidationServiceProtocol

    private let iapSettingsStorageManager: IAPSettingsStorageManagerProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let analytics: Analytics

    /// Protected `MutableState` value that provides thread-safe access to state values.
    @Protected
    private var mutableState = MutableState()

    init(
        paymentQueue: SKPaymentQueue = SKPaymentQueue.default(),
        paymentsCache: IAPPaymentsCacheProtocol = IAPPaymentsCache.shared,
        receiptValidationService: IAPReceiptValidationServiceProtocol = IAPReceiptValidationService(
            coursePaymentsNetworkService: CoursePaymentsNetworkService(
                coursePaymentsAPI: CoursePaymentsAPI()
            )
        ),
        iapSettingsStorageManager: IAPSettingsStorageManagerProtocol = IAPSettingsStorageManager(),
        userAccountService: UserAccountServiceProtocol = UserAccountService(),
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.paymentQueue = paymentQueue
        self.paymentsCache = paymentsCache
        self.receiptValidationService = receiptValidationService
        self.iapSettingsStorageManager = iapSettingsStorageManager
        self.userAccountService = userAccountService
        self.analytics = analytics
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

    func buy(courseID: Course.IdType, promoCode: String?, product: SKProduct) {
        if self.canMakePayments() {
            self.paymentsCache.insertCoursePayment(courseID: courseID, promoCode: promoCode, product: product)
            self.paymentQueue.add(SKPayment(product: product))
        } else {
            self.delegate?.iapPaymentsService(self, didFailPurchaseCourse: courseID, withError: Error.paymentNotAllowed)
        }
    }

    func retryValidateReceipt(courseID: Course.IdType, productIdentifier: IAPProductIdentifier) {
        func reportRetryValidateReceiptFailed(error: Swift.Error) {
            self.delegate?.iapPaymentsService(
                self,
                didFailPurchaseCourse: courseID,
                withError: Error.paymentReceiptValidationFailed(originalError: error)
            )
        }

        guard let transaction = self.paymentQueue.transactions.first(
            where: { $0.payment.productIdentifier == productIdentifier }
        ), transaction.transactionState == .purchased else {
            return reportRetryValidateReceiptFailed(error: Error.paymentNotFoundTransactionForRetryValidateReceipt)
        }

        guard let payload = self.paymentsCache.getCoursePayment(for: transaction),
              payload.courseID == courseID else {
            return reportRetryValidateReceiptFailed(
                error: Error.paymentNotFoundTransactionPayloadForRetryValidateReceipt
            )
        }

        guard payload.userID == self.userAccountService.currentUserID else {
            return reportRetryValidateReceiptFailed(error: Error.paymentUserChanged)
        }

        self.validateReceipt(transaction: transaction, payload: payload, forceRefreshReceipt: true)
    }

    func finishAllTransactions() -> Int {
        let count = self.paymentQueue.transactions.count

        for transaction in self.paymentQueue.transactions {
            self.paymentsCache.removeCoursePayment(for: transaction)
            self.paymentQueue.finishTransaction(transaction)
        }

        return count
    }

    // MARK: Inner Types

    private struct MutableState {
        var courseIDByValidateReceiptFailedCount: [Course.IdType: Int] = [:]
        var courseIDByValidateReceiptWithRefresh: [Course.IdType: Bool] = [:]

        func isAutoRetryValidateReceiptOngoing(courseID: Course.IdType) -> Bool {
            let validateReceiptFailedCount = self.courseIDByValidateReceiptFailedCount[courseID, default: 0]
            let validateReceiptWithRefresh = self.courseIDByValidateReceiptWithRefresh[courseID, default: false]
            return validateReceiptFailedCount == 1 && validateReceiptWithRefresh
        }
    }

    enum Error: Swift.Error {
        case paymentNotAllowed
        case paymentCancelled(originalError: Swift.Error)
        case paymentFailed(originalError: Swift.Error?)
        case paymentUserChanged
        case paymentReceiptValidationFailed(originalError: Swift.Error)
        case paymentNotFoundTransactionForRetryValidateReceipt
        case paymentNotFoundTransactionPayloadForRetryValidateReceipt
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

        if let wrappedTransactionState = IAPPaymentTransactionState(transactionState: transaction.transactionState) {
            self.delegate?.iapPaymentsService(
                self,
                didReceiveTransactionState: wrappedTransactionState,
                forCourse: payload.courseID
            )
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

            #if BETA_PROFILE || DEBUG
            if let createCoursePaymentDelay = self.iapSettingsStorageManager.createCoursePaymentDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + createCoursePaymentDelay) {
                    self.validateReceipt(transaction: transaction, payload: payload)
                }
            } else {
                self.validateReceipt(transaction: transaction, payload: payload)
            }
            #else
            self.validateReceipt(transaction: transaction, payload: payload)
            #endif
        case .failed:
            if let skError = transaction.error as? SKError {
                if skError.code != .paymentCancelled {
                    self.delegate?.iapPaymentsService(
                        self,
                        didFailPurchaseCourse: payload.courseID,
                        withError: Error.paymentFailed(originalError: skError)
                    )
                } else {
                    self.delegate?.iapPaymentsService(
                        self,
                        didFailPurchaseCourse: payload.courseID,
                        withError: Error.paymentCancelled(originalError: skError)
                    )
                }
                print("IAPPaymentsService :: payment failed with error: \(skError)")
            } else {
                print("IAPPaymentsService :: payment failed with unknown error")
                self.delegate?.iapPaymentsService(
                    self,
                    didFailPurchaseCourse: payload.courseID,
                    withError: Error.paymentFailed(originalError: transaction.error)
                )
            }

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
        let courseID = payload.courseID

        self.receiptValidationService.validateCoursePayment(
            courseID: payload.courseID,
            price: payload.price,
            currencyCode: payload.currencyCode,
            promoCode: payload.promoCode,
            forceRefreshReceipt: forceRefreshReceipt
        ).done { _ in
            if self.mutableState.isAutoRetryValidateReceiptOngoing(courseID: courseID) {
                self.$mutableState.write { $0.courseIDByValidateReceiptWithRefresh[courseID] = false }
                self.analytics.send(.courseBuyReceiptRefreshed(id: courseID, successfully: true))
            }

            self.delegate?.iapPaymentsService(self, didPurchaseCourse: payload.courseID)

            self.paymentsCache.removeCoursePayment(for: transaction)
            self.paymentQueue.finishTransaction(transaction)
        }.catch { error in
            print("IAPPaymentsService :: failed validate payment with error: \(error)")

            if self.mutableState.isAutoRetryValidateReceiptOngoing(courseID: courseID) {
                self.$mutableState.write { $0.courseIDByValidateReceiptWithRefresh[courseID] = false }
                self.analytics.send(.courseBuyReceiptRefreshed(id: courseID, successfully: false))
            }

            self.$mutableState.write { $0.courseIDByValidateReceiptFailedCount[courseID, default: 0] += 1 }

            if self.$mutableState.read({ $0.courseIDByValidateReceiptFailedCount[courseID] }) == 1 {
                self.$mutableState.write { $0.courseIDByValidateReceiptWithRefresh[courseID] = true }

                self.retryValidateReceipt(
                    courseID: courseID,
                    productIdentifier: transaction.payment.productIdentifier
                )
            } else {
                self.$mutableState.write { $0.courseIDByValidateReceiptWithRefresh[courseID] = false }

                let originalError: Swift.Error = {
                    if let receiptValidationServiceError = error as? IAPReceiptValidationService.Error {
                        switch receiptValidationServiceError {
                        case .noAppStoreReceiptPresent, .invalidPaymentData, .invalidFinalStatus:
                            return receiptValidationServiceError
                        case .requestFailed(let originalError):
                            return originalError
                        }
                    }
                    return error
                }()

                self.delegate?.iapPaymentsService(
                    self,
                    didFailPurchaseCourse: courseID,
                    withError: Error.paymentReceiptValidationFailed(originalError: originalError)
                )
            }
        }
    }
}

// MARK: - IAPPaymentTransactionState -

enum IAPPaymentTransactionState {
    case purchasing
    case purchased
    case failed
    case restored
    case deferred
}

extension IAPPaymentTransactionState {
    init?(transactionState: SKPaymentTransactionState) {
        switch transactionState {
        case .purchasing:
            self = .purchasing
        case .purchased:
            self = .purchased
        case .failed:
            self = .failed
        case .restored:
            self = .restored
        case .deferred:
            self = .restored
        @unknown default:
            return nil
        }
    }
}
