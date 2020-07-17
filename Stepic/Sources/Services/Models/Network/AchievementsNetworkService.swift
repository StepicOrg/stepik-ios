import Foundation
import PromiseKit

protocol AchievementsNetworkServiceProtocol: AnyObject {
    func fetch(kind: String?, page: Int) -> Promise<([Achievement], Meta)>
}

extension AchievementsNetworkServiceProtocol {
    func fetch(page: Int) -> Promise<([Achievement], Meta)> {
        self.fetch(kind: nil, page: page)
    }
}

final class AchievementsNetworkService: AchievementsNetworkServiceProtocol {
    private let achievementsAPI: AchievementsAPI

    init(achievementsAPI: AchievementsAPI = AchievementsAPI()) {
        self.achievementsAPI = achievementsAPI
    }

    func fetch(kind: String?, page: Int) -> Promise<([Achievement], Meta)> {
        Promise { seal in
            self.achievementsAPI.retrieve(kind: kind, page: page).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
