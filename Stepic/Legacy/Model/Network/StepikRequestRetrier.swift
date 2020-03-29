import Alamofire
import PromiseKit

final class StepikRequestRetrier: RequestRetrier {
    private static let unauthorizedErrorStatusCode = 401

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        if let response = request.task?.response as? HTTPURLResponse,
           response.statusCode == Self.unauthorizedErrorStatusCode && request.retryCount == 0 {
            checkToken().done {
                completion(.retry)
            }.catch { error in
                completion(.doNotRetryWithError(error))
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}
