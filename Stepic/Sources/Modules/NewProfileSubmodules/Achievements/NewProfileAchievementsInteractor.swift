import Foundation
import PromiseKit

protocol NewProfileAchievementsInteractorProtocol {
    func doAchievementsLoad(request: NewProfileAchievements.AchievementsLoad.Request)
}

final class NewProfileAchievementsInteractor: NewProfileAchievementsInteractorProtocol {
    private static let maxProfileAchievementsCount = 5

    private let presenter: NewProfileAchievementsPresenterProtocol
    private let provider: NewProfileAchievementsProviderProtocol

    private var currentUser: User?
    private var didLoadAchievements = false

    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileAchievementsInteractor.AchievementsFetch",
        qos: .userInitiated
    )

    init(
        presenter: NewProfileAchievementsPresenterProtocol,
        provider: NewProfileAchievementsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doAchievementsLoad(request: NewProfileAchievements.AchievementsLoad.Request) {
        guard let currentUserID = self.currentUser?.id else {
            return
        }

        self.fetchQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            print("NewProfileAchievementsInteractor :: start fetching achievements")

            strongSelf.fetchUserAchievements(userID: currentUserID).done { response in
                DispatchQueue.main.async {
                    print("NewProfileAchievementsInteractor :: finish fetching achievements")
                    switch response.result {
                    case .success:
                        strongSelf.didLoadAchievements = true
                        strongSelf.presenter.presentAchievements(response: response)
                    case .failure:
                        break
                    }
                }
            }.ensure {
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                print("NewProfileAchievementsInteractor :: failed fetch achievements, error = \(error)")
                DispatchQueue.main.async {
                    strongSelf.presenter.presentAchievements(response: .init(result: .failure(error)))
                }
            }
        }
    }

    func fetchUserAchievements(userID: User.IdType) -> Promise<NewProfileAchievements.AchievementsLoad.Response> {
        // kind -> isObtained
        var allUniqueKinds = [String: Bool]()

        // Load achievements while we have less kinds than maxProfileAchievementsCount (+kinds from allUniqueKinds)
        let achievementsBreakCondition: ([Achievement]) -> Bool = { achievements -> Bool in
            // kind -> isObtained
            var uniqueKinds = Set<String>()

            for achievement in achievements where allUniqueKinds[achievement.kind] == nil {
                uniqueKinds.insert(achievement.kind)
            }

            return allUniqueKinds.count + uniqueKinds.count >= Self.maxProfileAchievementsCount
        }

        // Load progresses while we have less unique kinds than maxProfileAchievementsCount
        let progressesBreakCondition: ([AchievementProgress]) -> Bool = { progresses -> Bool in
            // kind -> isObtained
            var uniqueKinds = [String: Bool]()

            for progress in progresses {
                uniqueKinds[progress.kind] = (uniqueKinds[progress.kind] ?? false) || (progress.obtainDate != nil)
            }

            return uniqueKinds.count >= Self.maxProfileAchievementsCount
        }

        func fetchMoreAchievementKinds() -> Promise<[String]> {
            self.provider.fetchAchievements(breakCondition: achievementsBreakCondition).then(on: self.fetchQueue) {
                allAchievements -> Promise<[String]> in
                for achievement in allAchievements {
                    allUniqueKinds[achievement.kind] = false
                    if allUniqueKinds.count >= Self.maxProfileAchievementsCount {
                        break
                    }
                }

                let kinds = allUniqueKinds.map { key, value in (key, value) }
                return .value(kinds.sorted(by: { $0.1 && !$1.1 }).map { $0.0 })
            }
        }

        return Promise { seal in
            self.provider.fetchAchievementProgresses(
                userID: userID,
                withBreakCondition: progressesBreakCondition
            ).then(on: self.fetchQueue) { allProgresses -> Promise<[String]> in
                for progress in allProgresses {
                    let isObtained = (allUniqueKinds[progress.kind] ?? false) || (progress.obtainDate != nil)
                    allUniqueKinds[progress.kind] = isObtained
                }

                if allUniqueKinds.count < Self.maxProfileAchievementsCount {
                    // We should load more achievements with unknown progress
                    return fetchMoreAchievementKinds()
                } else {
                    let kinds = allUniqueKinds.map { key, value in (key, value) }
                    return .value(kinds.sorted(by: { $0.1 && !$1.1 }).map { $0.0 })
                }
            }.then(on: self.fetchQueue) { kinds -> Promise<[AchievementProgressData]> in
                let fetchAchievementProgressPromises = kinds.compactMap { [weak self] kind in
                    self?.provider.fetchAchievementProgress(userID: userID, kind: kind)
                }
                return when(fulfilled: fetchAchievementProgressPromises)
            }.done(on: self.fetchQueue) { achievementProgressData in
                seal.fulfill(.init(result: .success(achievementProgressData)))
            }.catch { error in
                if self.didLoadAchievements {
                    // Offline mode: we already presented cached achievements, but network request failed
                    seal.fulfill(.init(result: .failure(Error.networkFetchFailed)))
                } else {
                    seal.reject(error)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
    }
}

extension NewProfileAchievementsInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.currentUser = user
        self.doAchievementsLoad(request: .init())
    }
}
