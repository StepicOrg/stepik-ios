import Alamofire

final class StepikRequestInterceptor: RequestInterceptor {
    private let adapter: RequestAdapter
    private let retrier: RequestRetrier

    init(
        adapter: RequestAdapter = StepikRequestAdapter(),
        retrier: RequestRetrier = StepikRequestRetrier()
    ) {
        self.adapter = adapter
        self.retrier = retrier
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        self.adapter.adapt(urlRequest, for: session, completion: completion)
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        self.retrier.retry(request, for: session, dueTo: error, completion: completion)
    }
}
