import Alamofire
import Foundation
import SwiftyJSON

// MARK: JSON Response Serializer -

public final class SwiftyJSONResponseSerializer: ResponseSerializer {
    public let dataPreprocessor: DataPreprocessor
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    /// `JSONSerialization.ReadingOptions` used when serializing a response.
    public let readingOptions: JSONSerialization.ReadingOptions

    /// Creates an instance with the provided values.
    ///
    /// - Parameters:
    ///   - dataPreprocessor:    `DataPreprocessor` used to prepare the received `Data` for serialization.
    ///   - emptyResponseCodes:  The HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    ///   - emptyRequestMethods: The HTTP request methods for which empty responses are allowed. `[.head]` by default.
    ///   - readingOptions:      The options to use. `.allowFragments` by default.
    public init(
        dataPreprocessor: DataPreprocessor = SwiftyJSONResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = SwiftyJSONResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = SwiftyJSONResponseSerializer.defaultEmptyRequestMethods,
        readingOptions: JSONSerialization.ReadingOptions = .allowFragments
    ) {
        self.dataPreprocessor = dataPreprocessor
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        self.readingOptions = readingOptions
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> JSON {
        guard error == nil else { throw error! }

        guard var data = data, !data.isEmpty else {
            guard self.emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }

            return JSON(booleanLiteral: false)
        }

        data = try self.dataPreprocessor.preprocess(data)

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: self.readingOptions)
            return JSON(json)
        } catch {
            throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
}

// MARK: - Request for SwiftyJSON -

extension DataRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter options:
    ///     The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue = .main,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        _ completionHandler: @escaping (AFDataResponse<JSON>) -> Void
    ) -> Self {
        self.response(
            queue: queue,
            responseSerializer: SwiftyJSONResponseSerializer(readingOptions: options),
            completionHandler: completionHandler
        )
    }
}
