import Foundation
import PromiseKit

protocol AchievementProgressesNetworkServiceProtocol: AnyObject {
    func fetch(userID: User.IdType, kind: String?, page: Int) -> Promise<([AchievementProgress], Meta)>
    func fetchWithSortingByObtainDateDesc(
        userID: User.IdType,
        kind: String?,
        page: Int
    ) -> Promise<([AchievementProgress], Meta)>
}

final class AchievementProgressesNetworkService: AchievementProgressesNetworkServiceProtocol {
    private let achievementProgressesAPI: AchievementProgressesAPI

    init(achievementProgressesAPI: AchievementProgressesAPI = AchievementProgressesAPI()) {
        self.achievementProgressesAPI = achievementProgressesAPI
    }

    func fetch(userID: User.IdType, kind: String?, page: Int) -> Promise<([AchievementProgress], Meta)> {
        Promise { seal in
            self.achievementProgressesAPI
                .retrieve(userID: userID, kind: kind, order: nil, page: page)
                .done { seal.fulfill($0) }
                .catch { _ in seal.reject(Error.fetchFailed) }
        }
    }

    func fetchWithSortingByObtainDateDesc(
        userID: User.IdType,
        kind: String?,
        page: Int
    ) -> Promise<([AchievementProgress], Meta)> {
        Promise { seal in
            self.achievementProgressesAPI
                .retrieve(userID: userID, kind: kind, order: .obtainDateDesc, page: page)
                .done { seal.fulfill($0) }
                .catch { _ in seal.reject(Error.fetchFailed) }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
