import Foundation
import PromiseKit
import StoreKit

protocol IAPServiceProtocol: AnyObject {
    func fetchProducts() -> Promise<[SKProduct]>
    func fetchProduct(for course: Course) -> Promise<SKProduct?>

    func getLocalizedPrice(for product: SKProduct) -> String?
    func getLocalizedPrice(for course: Course) -> Guarantee<String?>
    func getLocalizedPrice(for tier: String?) -> Guarantee<String?>

    func startObservingPayments()
    func stopObservingPayments()

    func canMakePayments() -> Bool
    func canBuyCourse(_ course: Course) -> Bool

    func buy(course: Course, delegate: IAPServiceDelegate?)
    func retryValidateReceipt(course: Course, delegate: IAPServiceDelegate?)
}

extension IAPServiceProtocol {
    func prefetchProducts(delay: DispatchTimeInterval = .seconds(3)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.fetchProducts().cauterize()
        }
    }

    func getLocalizedPrices(priceTier: String?, promoTier: String?) -> Guarantee<(price: String?, promo: String?)> {
        if (priceTier?.isEmpty ?? true) && (promoTier?.isEmpty ?? true) {
            return .value((nil, nil))
        }

        return Guarantee { seal in
            when(
                fulfilled: self.getLocalizedPrice(for: priceTier),
                getLocalizedPrice(for: promoTier)
            ).done { priceTierLocalizedPrice, promoTierLocalizedPrice in
                seal((priceTierLocalizedPrice, promoTierLocalizedPrice))
            }.catch { _ in
                seal((nil, nil))
            }
        }
    }

    func getLocalizedPrices(mobileTier: MobileTier) -> Guarantee<(price: String?, promo: String?)> {
        self.getLocalizedPrices(priceTier: mobileTier.priceTier, promoTier: mobileTier.promoTier)
    }

    func getLocalizedPrices(mobileTier: MobileTierPlainObject) -> Guarantee<(price: String?, promo: String?)> {
        self.getLocalizedPrices(priceTier: mobileTier.priceTier, promoTier: mobileTier.promoTier)
    }
}

final class IAPService: IAPServiceProtocol {
    static let shared = IAPService()

    private let productsService: IAPProductsServiceProtocol
    private let paymentsService: IAPPaymentsServiceProtocol

    private var products: [SKProduct] = []
    private var coursePaymentRequests: Set<CoursePaymentRequest> = []

    private let mutex = PThreadMutex(type: .recursive)

    private init(
        productsService: IAPProductsServiceProtocol = IAPProductsService(),
        paymentsService: IAPPaymentsServiceProtocol = IAPPaymentsService()
    ) {
        self.productsService = productsService
        self.paymentsService = paymentsService
        self.paymentsService.delegate = self
    }

    // MARK: Products

    func fetchProduct(for course: Course) -> Promise<SKProduct?> {
        guard let priceTier = course.priceTier else {
            return Promise(error: Error.unsupportedCourse)
        }

        let productIdentifier = self.productsService.makeProductIdentifier(priceTier: priceTier)

        return self.fetchProduct(with: productIdentifier)
    }

    func fetchProducts() -> Promise<[SKProduct]> {
        Promise { seal in
            self.productsService.fetchProducts().done { products in
                if products.isEmpty {
                    seal.reject(Error.noProductsFound)
                } else {
                    self.mutex.unbalancedLock()
                    defer { self.mutex.unbalancedUnlock() }

                    self.products = products

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
        if let currencySymbol = product.priceLocale.currencySymbol {
            return FormatterHelper.price(product.price.floatValue, currencySymbol: currencySymbol)
        } else if let currencyCode = product.priceLocale.currencyCode {
            return FormatterHelper.price(product.price.floatValue, currencyCode: currencyCode)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            return formatter.string(from: product.price)
        }
    }

    func getLocalizedPrice(for course: Course) -> Guarantee<String?> {
        guard let priceTier = course.priceTier else {
            return Guarantee.value(nil)
        }

        let productIdentifier = self.productsService.makeProductIdentifier(priceTier: priceTier)

        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        if let product = self.products.first(where: { $0.productIdentifier == productIdentifier }) {
            return Guarantee.value(self.getLocalizedPrice(for: product))
        }

        return Guarantee { seal in
            self.fetchProduct(for: course).compactMap { $0 }.done { product in
                self.mutex.unbalancedLock()
                defer { self.mutex.unbalancedUnlock() }

                if !self.products.contains(where: { $0.productIdentifier == productIdentifier }) {
                    self.products.append(product)
                }

                seal(self.getLocalizedPrice(for: product))
            }.catch { _ in
                seal(nil)
            }
        }
    }

    func getLocalizedPrice(for tier: String?) -> Guarantee<String?> {
        guard let tier = tier, !tier.isEmpty else {
            return .value(nil)
        }

        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        if let product = self.products.first(where: { $0.productIdentifier == tier }) {
            return .value(self.getLocalizedPrice(for: product))
        }

        return Guarantee { seal in
            self.fetchProduct(with: tier).compactMap { $0 }.done { product in
                self.mutex.unbalancedLock()
                defer { self.mutex.unbalancedUnlock() }

                if !self.products.contains(where: { $0.productIdentifier == tier }) {
                    self.products.append(product)
                }

                seal(self.getLocalizedPrice(for: product))
            }.catch { _ in
                seal(nil)
            }
        }
    }

    private func fetchProduct(with productIdentifier: IAPProductIdentifier) -> Promise<SKProduct?> {
        guard self.productsService.canFetchProduct(with: productIdentifier) else {
            return Promise(error: Error.unsupportedCourse)
        }

        return Promise { seal in
            self.productsService.fetchProduct(productIdentifier: productIdentifier).done { product in
                seal.fulfill(product)
            }.catch { _ in
                seal.reject(Error.productsRequestFailed)
            }
        }
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

    func canBuyCourse(_ course: Course) -> Bool {
        guard let priceTier = course.priceTier, priceTier > 0 else {
            return false
        }

        let productIdentifier = self.productsService.makeProductIdentifier(priceTier: priceTier)

        return course.isPaid && self.productsService.canFetchProduct(with: productIdentifier)
    }

    func buy(course: Course, delegate: IAPServiceDelegate?) {
        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        let courseID = course.id
        let request = CoursePaymentRequest(courseID: courseID, delegate: delegate)

        if self.coursePaymentRequests.contains(request) {
            return
        }

        self.coursePaymentRequests.insert(request)

        self.fetchProduct(for: course).done { productOrNil in
            if let product = productOrNil {
                self.paymentsService.buy(courseID: courseID, promoCode: nil, product: product)
            } else {
                self.handleCoursePaymentFailed(courseID: courseID, error: Error.productsRequestFailed)
            }
        }.catch { error in
            self.handleCoursePaymentFailed(courseID: courseID, error: error)
        }
    }

    func retryValidateReceipt(course: Course, delegate: IAPServiceDelegate?) {
        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        let request = CoursePaymentRequest(courseID: course.id, delegate: delegate)
        self.coursePaymentRequests.insert(request)

        let productIdentifier = self.productsService.makeProductIdentifier(priceTier: course.priceTier.require())

        self.paymentsService.retryValidateReceipt(courseID: course.id, productIdentifier: productIdentifier)
    }

    // MARK: Types

    private final class CoursePaymentRequest: Hashable {
        let courseID: Course.IdType
        weak var delegate: IAPServiceDelegate?

        init(courseID: Course.IdType, delegate: IAPServiceDelegate?) {
            self.courseID = courseID
            self.delegate = delegate
        }

        static func == (lhs: CoursePaymentRequest, rhs: CoursePaymentRequest) -> Bool {
            lhs.courseID == rhs.courseID
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.courseID)
        }
    }

    enum Error: Swift.Error {
        /// The course unsupported by mobile payment.
        case unsupportedCourse
        /// Indicates that the product identifiers could not be found.
        case noProductIDsFound
        /// No IAP products were returned by the App Store because none was found.
        case noProductsFound
        /// The app cannot request App Store about available IAP products for some reason.
        case productsRequestFailed
        /// The user cancelled an initialized purchase process.
        case paymentWasCancelled
        /// Indicates that the course payment failed.
        case paymentFailed
        /// The IAP is not allowed on this device.
        case paymentNotAllowed
        /// Indicates that the current user changed during payment.
        case paymentUserChanged
        /// The receipt validation failed
        case paymentReceiptValidationFailed
    }
}

// MARK: - IAPService: IAPPaymentsServiceDelegate -

extension IAPService: IAPPaymentsServiceDelegate {
    func iapPaymentsService(_ service: IAPPaymentsServiceProtocol, didPurchaseCourse courseID: Course.IdType) {
        self.handleCoursePaymentSucceed(courseID: courseID)
    }

    func iapPaymentsService(
        _ service: IAPPaymentsServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    ) {
        self.handleCoursePaymentFailed(courseID: courseID, error: error)
    }

    // MARK: Private Helpers

    private func handleCoursePaymentSucceed(courseID: Course.IdType) {
        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        let requestDelegate = self.getCoursePaymentRequestDelegate(courseID: courseID)
        requestDelegate.iapService(self, didPurchaseCourse: courseID)

        self.coursePaymentRequests.remove(CoursePaymentRequest(courseID: courseID, delegate: nil))
    }

    private func handleCoursePaymentFailed(courseID: Course.IdType, error: Swift.Error) {
        self.mutex.unbalancedLock()
        defer { self.mutex.unbalancedUnlock() }

        let requestDelegate = self.getCoursePaymentRequestDelegate(courseID: courseID)

        if let paymentsServiceError = error as? IAPPaymentsService.Error {
            switch paymentsServiceError {
            case .paymentFailed:
                requestDelegate.iapService(self, didFailPurchaseCourse: courseID, withError: Error.paymentFailed)
            case .paymentNotAllowed:
                requestDelegate.iapService(self, didFailPurchaseCourse: courseID, withError: Error.paymentNotAllowed)
            case .paymentUserChanged:
                requestDelegate.iapService(self, didFailPurchaseCourse: courseID, withError: Error.paymentUserChanged)
            case .paymentCancelled:
                requestDelegate.iapService(self, didFailPurchaseCourse: courseID, withError: Error.paymentWasCancelled)
            case .paymentReceiptValidationFailed:
                requestDelegate.iapService(
                    self,
                    didFailPurchaseCourse: courseID,
                    withError: Error.paymentReceiptValidationFailed
                )
            }
        } else {
            requestDelegate.iapService(self, didFailPurchaseCourse: courseID, withError: Error.paymentFailed)
        }

        self.coursePaymentRequests.remove(CoursePaymentRequest(courseID: courseID, delegate: nil))
    }

    private func getCoursePaymentRequestDelegate(courseID: Course.IdType) -> IAPServiceDelegate {
        if let requestDelegate = self.coursePaymentRequests.first(where: { $0.courseID == courseID })?.delegate {
            return requestDelegate
        } else {
            return DefaultIAPServiceDelegate()
        }
    }
}

// MARK: - IAPService.Error: LocalizedError -

extension IAPService.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedCourse, .noProductIDsFound, .noProductsFound, .productsRequestFailed, .paymentWasCancelled:
            return nil
        case .paymentNotAllowed:
            return NSLocalizedString("IAPPurchaseErrorPaymentNotAllowed", comment: "")
        case .paymentUserChanged:
            return NSLocalizedString("IAPPurchaseErrorPaymentUserChanged", comment: "")
        case .paymentReceiptValidationFailed:
            return NSLocalizedString("IAPPurchaseErrorPaymentReceiptValidationFailed", comment: "")
        case .paymentFailed:
            return NSLocalizedString("IAPPurchaseErrorPaymentFailed", comment: "")
        }
    }
}
