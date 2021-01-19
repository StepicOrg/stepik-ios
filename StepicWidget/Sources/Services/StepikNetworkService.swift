import Foundation

typealias Result<Success> = Swift.Result<Success, Error>

final class StepikNetworkService {
    static let shared = StepikNetworkService()

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: configuration)
        return session
    }()

    private var allHTTPHeaderFields: [String: String] {
        let headers: [HTTPHeader] = [
            .userAgent, .contentType, .authorization(bearerToken: self.token?.accessToken ?? "")
        ]
        let namesAndValues = headers.map { ($0.name, $0.value) }

        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }

    var token: StepikWidgetToken?

    func request(_ endpoint: Endpoint, then completionHandler: @escaping (Result<Data>) -> Void) {
        guard let url = endpoint.url else {
            return completionHandler(.failure(Error.invalidURL))
        }

        guard self.token?.accessToken != nil else {
            return completionHandler(.failure(Error.noAccessToken))
        }

        var request = URLRequest(url: url)

        for (name, value) in self.allHTTPHeaderFields {
            request.setValue(value, forHTTPHeaderField: name)
        }

        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completionHandler(.failure(Error.network(error)))
            }

            let acceptableStatusCodes = 200..<300

            guard let httpResponse = response as? HTTPURLResponse,
                  acceptableStatusCodes.contains(httpResponse.statusCode) else {
                return completionHandler(.failure(Error.responseValidationFailed))
            }

            let result = data.map(Result.success) ?? .failure(Error.network(error))

            completionHandler(result)
        }

        task.resume()
    }

    func request<Response: Decodable>(
        _ endpoint: Endpoint,
        then completionHandler: @escaping (Result<Response>) -> Void
    ) {
        self.request(endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(Response.self, from: data)

                    DispatchQueue.main.async {
                        completionHandler(.success(decodedResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.failure(Error.decode(error)))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }

    func getUserCourses(completionHandler: @escaping (Result<UserCoursesResponse>) -> Void) {
        self.request(.getUserCourses(), then: completionHandler)
    }

    func getCourses(ids: [Int], then completionHandler: @escaping (Result<CoursesResponse>) -> Void) {
        self.request(.getCourses(ids: ids)) { (result: Result<CoursesResponse>) in
            switch result {
            case .success(let coursesResponse):
                let sortedCourses = coursesResponse.courses.reordered(order: ids, transform: { $0.id })
                let resultCoursesResponse = CoursesResponse(meta: coursesResponse.meta, courses: sortedCourses)
                completionHandler(.success(resultCoursesResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func getProgresses(ids: [String], then completionHandler: @escaping (Result<ProgressesResponse>) -> Void) {
        self.request(.getProgresses(ids: ids)) { (result: Result<ProgressesResponse>) in
            switch result {
            case .success(let progressesResponse):
                let sortedProgresses = progressesResponse.progresses.reordered(order: ids, transform: { $0.id })
                let resultProgressesResponse = ProgressesResponse(
                    meta: progressesResponse.meta,
                    progresses: sortedProgresses
                )
                completionHandler(.success(resultProgressesResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    enum Error: Swift.Error {
        case invalidURL
        case noAccessToken
        case network(Swift.Error?)
        case responseValidationFailed
        case decode(Swift.Error)
    }
}

// MARK: - Endpoint -

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    var url: URL? {
        var components = URLComponents()
        components.scheme = WidgetConstants.URL.scheme
        components.host = WidgetConstants.URL.host
        components.path = self.path
        components.queryItems = self.queryItems.isEmpty ? nil : self.queryItems

        return components.url
    }
}

extension Endpoint {
    static func getUserCourses() -> Endpoint {
        Endpoint(path: "/api/user-courses", queryItems: [])
    }

    static func getCourses(ids: [Int]) -> Endpoint {
        Endpoint(
            path: "/api/courses",
            queryItems: Self.mapIDs(ids)
        )
    }

    static func getProgresses(ids: [String]) -> Endpoint {
        Endpoint(
            path: "/api/progresses",
            queryItems: Self.mapIDs(ids)
        )
    }

    private static func mapIDs(_ ids: [Any]) -> [URLQueryItem] {
        ids.map { URLQueryItem(name: "ids[]", value: "\($0)") }
    }
}

// MARK: - HTTPHeader -

struct HTTPHeader {
    let name: String
    let value: String

    static var userAgent: HTTPHeader {
        let value: String = {
            guard let bundleID = Bundle.main.bundleIdentifier,
                  let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                  let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String else {
                return "Stepik (Widget Extension)"
            }

            let osVersion = [
                "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)",
                "\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)",
                "\(ProcessInfo.processInfo.operatingSystemVersion.patchVersion)"
            ].joined(separator: ".")

            return "Stepik/\(version) (Widget Extension) (\(bundleID); build \(build); iOS \(osVersion))"
        }()

        return HTTPHeader(name: "User-Agent", value: value)
    }

    static var contentType: HTTPHeader {
        HTTPHeader(name: "Content-Type", value: "application/json")
    }

    static func authorization(bearerToken: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: "Bearer \(bearerToken)")
    }
}
