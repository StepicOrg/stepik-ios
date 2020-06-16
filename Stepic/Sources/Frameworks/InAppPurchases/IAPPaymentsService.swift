import Foundation
import PromiseKit
import StoreKit

protocol IAPPaymentsServiceProtocol: AnyObject {
    func startObserving()
    func stopObserving()

    func canMakePayments() -> Bool

    func buy(courseID: Course.IdType, product: SKProduct) -> Promise<Void>
}

final class IAPPaymentsService: NSObject, IAPPaymentsServiceProtocol {
    private let paymentQueue: SKPaymentQueue
    private let receiptValidationService: IAPReceiptValidationServiceProtocol

    private var courseID: Course.IdType?
    private var product: SKProduct?

    private var onBuyProductCompletionHandler: ((Swift.Result<Bool, Error>) -> Void)?

    init(
        paymentQueue: SKPaymentQueue = SKPaymentQueue.default(),
        receiptValidationService: IAPReceiptValidationServiceProtocol = IAPReceiptValidationService(
            coursePaymentsNetworkService: CoursePaymentsNetworkService(
                coursePaymentsAPI: CoursePaymentsAPI()
            )
        )
    ) {
        self.paymentQueue = paymentQueue
        self.receiptValidationService = receiptValidationService
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

    func buy(courseID: Course.IdType, product: SKProduct) -> Promise<Void> {
        self.courseID = courseID
        self.product = product

        return Promise { seal in
            let payment = SKPayment(product: product)
            self.paymentQueue.add(payment)

            self.onBuyProductCompletionHandler = { result in
                switch result {
                case .success:
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case paymentCancelled
        case paymentFailed
    }
}

extension IAPPaymentsService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.receiptValidationService.validateCoursePayment(
                    courseID: courseID,
                    price: product.price.doubleValue,
                    currencyCode: product.priceLocale.currencyCode
                ).done { _ in
                    self.onBuyProductCompletionHandler?(.success(true))
                    self.paymentQueue.finishTransaction(transaction)
                }.catch { error in
                    print("IAPPaymentsService :: failed validate payment with error: \(error)")
                    self.onBuyProductCompletionHandler?(.failure(Error.paymentFailed))
                }
            case .failed:
                if let skError = transaction.error as? SKError {
                    if skError.code != .paymentCancelled {
                        self.onBuyProductCompletionHandler?(.failure(Error.paymentFailed))
                    } else {
                        self.onBuyProductCompletionHandler?(.failure(Error.paymentCancelled))
                    }
                    print("IAPPaymentsService :: payment failed with error: \(skError)")
                } else {
                    print("IAPPaymentsService :: payment failed with unknown error")
                    self.onBuyProductCompletionHandler?(.failure(Error.paymentFailed))
                }
                self.paymentQueue.finishTransaction(transaction)
            case .purchasing, .deferred, .restored:
                break
            @unknown default:
                break
            }
        }
    }
}
