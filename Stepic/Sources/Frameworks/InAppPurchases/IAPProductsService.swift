import Foundation
import PromiseKit
import StoreKit

typealias IAPProductIdentifier = String

protocol IAPProductsServiceProtocol: AnyObject {
    func getProductIdentifiers() -> Set<IAPProductIdentifier>
    func fetchProducts(productIdentifiers: Set<IAPProductIdentifier>) -> Promise<[SKProduct]>
}

extension IAPProductsServiceProtocol {
    func fetchProducts() -> Promise<[SKProduct]> {
        self.fetchProducts(productIdentifiers: self.getProductIdentifiers())
    }
}

final class IAPProductsService: IAPProductsServiceProtocol {
    private struct ProductQuery {
        let request: IAPProductRequest
        var completionHandlers: [IAPProductRequest.CompletionHandler]
    }

    // Store requests in a dictionary by product ids.
    private var productRequests: [Set<IAPProductIdentifier>: ProductQuery] = [:]

    func getProductIdentifiers() -> Set<IAPProductIdentifier> {
        guard let url = Bundle.main.url(forResource: "IAPProductIDs", withExtension: "plist") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(
                from: data,
                options: .mutableContainersAndLeaves,
                format: nil
            ) as? [IAPProductIdentifier] ?? []
            return Set(productIDs)
        } catch {
            return []
        }
    }

    func fetchProducts(productIdentifiers: Set<IAPProductIdentifier>) -> Promise<[SKProduct]> {
        if productIdentifiers.isEmpty {
            return Promise(error: Error.noProductIDsFound)
        }

        return Promise { seal in
            self.fetchProducts(productIdentifiers: productIdentifiers) { result in
                switch result {
                case .success(let products):
                    seal.fulfill(products)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    private func fetchProducts(
        productIdentifiers: Set<IAPProductIdentifier>,
        completionHandler: @escaping IAPProductRequest.CompletionHandler
    ) {
        if self.productRequests[productIdentifiers] == nil {
            let request = IAPProductRequest(productIdentifiers: productIdentifiers) { result in
                if let query = self.productRequests[productIdentifiers] {
                    for completionHandler in query.completionHandlers {
                        completionHandler(result)
                    }
                    self.productRequests[productIdentifiers] = nil
                } else {
                    completionHandler(result)
                }
            }

            self.productRequests[productIdentifiers] = ProductQuery(
                request: request,
                completionHandlers: [completionHandler]
            )

            request.start()
        } else {
            self.productRequests[productIdentifiers]?.completionHandlers.append(completionHandler)
        }
    }

    enum Error: Swift.Error {
        /// Indicates that the product identifiers could not be found.
        case noProductIDsFound
    }
}

fileprivate final class IAPProductRequest: NSObject, SKProductsRequestDelegate {
    typealias CompletionHandler = (Swift.Result<[SKProduct], Swift.Error>) -> Void

    private let request: SKProductsRequest
    private let completionHandler: CompletionHandler?

    init(productIdentifiers: Set<IAPProductIdentifier>, completionHandler: CompletionHandler?) {
        self.request = SKProductsRequest(productIdentifiers: productIdentifiers)
        self.completionHandler = completionHandler
        super.init()
        self.request.delegate = self
    }

    deinit {
        self.request.delegate = nil
    }

    func start() {
        self.request.start()
    }

    func cancel() {
        self.request.cancel()
    }

    // MARK: SKProductsRequestDelegate

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.completionHandler?(.success(response.products))
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.completionHandler?(.failure(error))
        }
    }
}
