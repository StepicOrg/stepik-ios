import Alamofire

final class StepikRequestAdapter: RequestAdapter {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest

        for (headerField, value) in AuthInfo.shared.initialHTTPHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: headerField)
        }

        completion(.success(urlRequest))
    }
}
