import Foundation
import PromiseKit
import StoreKit

protocol IAPServiceProtocol: AnyObject {
    func fetchProducts() -> Promise<[SKProduct]>
    func getLocalizedPrice(for product: SKProduct) -> String?

    func startObservingPayments()
    func stopObservingPayments()
    func canMakePayments() -> Bool

    func buy(course: Course) -> Promise<Void>
}

final class IAPService: IAPServiceProtocol {
    static let shared = IAPService()

    private let productsService: IAPProductsServiceProtocol
    private let paymentsService: IAPPaymentsServiceProtocol

    private init(
        productsService: IAPProductsServiceProtocol = IAPProductsService(),
        paymentsService: IAPPaymentsServiceProtocol = IAPPaymentsService()
    ) {
        self.productsService = productsService
        self.paymentsService = paymentsService
    }

    // MARK: Products

    func fetchProducts() -> Promise<[SKProduct]> {
        Promise { seal in
            self.productsService.fetchProducts().done { products in
                if products.isEmpty {
                    seal.reject(Error.noProductsFound)
                } else {
                    seal.fulfill(products)
                }
            }.catch { error in
                if let productsServiceError = error as? IAPProductsService.Error {
                    switch productsServiceError {
                    case .noProductIDsFound:
                        seal.reject(Error.noProductIDsFound)
                    }
                } else {
                    seal.reject(Error.productsRequestFailed)
                }
            }
        }
    }

    func getLocalizedPrice(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }

    // MARK: Payments

    func startObservingPayments() {
        self.paymentsService.startObserving()
    }

    func stopObservingPayments() {
        self.paymentsService.stopObserving()
    }

    func canMakePayments() -> Bool {
        self.paymentsService.canMakePayments()
    }

    func buy(course: Course) -> Promise<Void> {
        let courseID = course.id

        return Promise { seal in
            self.fetchProducts().compactMap { $0.first }.then { product -> Promise<Void> in
                self.paymentsService.buy(courseID: courseID, product: product)
            }.done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        /// Indicates that the product identifiers could not be found.
        case noProductIDsFound
        /// No IAP products were returned by the App Store because none was found.
        case noProductsFound
        /// The app cannot request App Store about available IAP products for some reason.
        case productsRequestFailed
        /// The user cancelled an initialized purchase process.
        case paymentWasCancelled
    }
}
