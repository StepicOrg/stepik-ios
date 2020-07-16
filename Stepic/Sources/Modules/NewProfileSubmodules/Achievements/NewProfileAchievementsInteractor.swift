import Foundation
import PromiseKit

protocol NewProfileAchievementsInteractorProtocol {
    func doAchievementsLoad(request: NewProfileAchievements.AchievementsLoad.Request)
    func doAchievementPresentation(request: NewProfileAchievements.AchievementPresentation.Request)
}

final class NewProfileAchievementsInteractor: NewProfileAchievementsInteractorProtocol {
    private static let maxProfileAchievementsCount = 5

    private let presenter: NewProfileAchievementsPresenterProtocol
    private let provider: NewProfileAchievementsProviderProtocol

    private var currentUserID: User.IdType?
    private var isCurrentUserProfile = false
    private var currentAchievements = [AchievementProgressData]()
    private var didLoadAchievements = false

    private let debouncer: DebouncerProtocol = Debouncer()

    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileAchievementsInteractor.AchievementsFetch"
    )

    init(
        presenter: NewProfileAchievementsPresenterProtocol,
        provider: NewProfileAchievementsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doAchievementsLoad(request: NewProfileAchievements.AchievementsLoad.Request) {
        guard let currentUserID = self.currentUserID else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            print("NewProfileAchievementsInteractor :: start fetching achievements")

            strongSelf.fetchUserAchievements(userID: currentUserID).done { response in
                DispatchQueue.main.async {
                    print("NewProfileAchievementsInteractor :: finish fetching achievements")
                    switch response.result {
                    case .success(let achievements):
                        strongSelf.currentAchievements = achievements
                        strongSelf.didLoadAchievements = true
                        strongSelf.presenter.presentAchievements(response: response)
                    case .failure:
                        break
                    }
                }
            }.ensure {
                strongSelf.debouncer.action = nil
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                print("NewProfileAchievementsInteractor :: failed fetch achievements, error = \(error)")
                DispatchQueue.main.async {
                    strongSelf.presenter.presentAchievements(response: .init(result: .failure(error)))
                }
            }
        }
    }

    func doAchievementPresentation(request: NewProfileAchievements.AchievementPresentation.Request) {
        if let achievement = self.currentAchievements.first(where: { $0.kind == request.uniqueIdentifier }) {
            self.presenter.presentAchievement(
                response: .init(achievementProgressData: achievement, isShareable: self.isCurrentUserProfile)
            )
        }
    }

    private func fetchUserAchievements(
        userID: User.IdType
    ) -> Promise<NewProfileAchievements.AchievementsLoad.Response> {
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
            self.provider.fetchAchievements(breakCondition: achievementsBreakCondition).then {
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
            ).then(on: .global(qos: .userInitiated)) { allProgresses -> Promise<[String]> in
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
            }.then(on: .global(qos: .userInitiated)) { kinds -> Promise<[AchievementProgressData]> in
                let fetchAchievementProgressPromises = kinds.compactMap { [weak self] kind in
                    self?.provider.fetchAchievementProgress(userID: userID, kind: kind)
                }
                return when(fulfilled: fetchAchievementProgressPromises)
            }.done { achievementsProgressesData in
                seal.fulfill(.init(result: .success(achievementsProgressesData)))
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
        self.currentUserID = user.id
        self.isCurrentUserProfile = isCurrentUserProfile

        if self.debouncer.action == nil {
            self.debouncer.action = { [weak self] in
                self?.doAchievementsLoad(request: .init())
            }
        }
    }
}
