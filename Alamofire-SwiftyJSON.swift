import Alamofire
import Foundation
import SwiftyJSON

// MARK: SwiftyJSON Response Serializer -

public final class SwiftyJSONResponseSerializer: ResponseSerializer {
    private let jsonResponseSerializer: JSONResponseSerializer

    public init(
        dataPreprocessor: DataPreprocessor = JSONResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = JSONResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = JSONResponseSerializer.defaultEmptyRequestMethods,
        options: JSONSerialization.ReadingOptions = .allowFragments
    ) {
        self.jsonResponseSerializer = JSONResponseSerializer(
            dataPreprocessor: dataPreprocessor,
            emptyResponseCodes: emptyResponseCodes,
            emptyRequestMethods: emptyRequestMethods,
            options: options
        )
    }

    public func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> JSON {
        let json = try self.jsonResponseSerializer.serialize(
            request: request,
            response: response,
            data: data,
            error: error
        )

        return JSON(json)
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
            responseSerializer: SwiftyJSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}
