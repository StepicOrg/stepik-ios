import Foundation
import PromiseKit

protocol NewProfileStreakNotificationsProviderProtocol {
    func hasSubmissions(userID: User.IdType) -> Guarantee<Bool>
    func fetchUserActivity(userID: User.IdType) -> Guarantee<UserActivity?>
}

extension NewProfileStreakNotificationsProviderProtocol {
    func fetchStreakLocalNotificationType(userID: User.IdType) -> Guarantee<StreakLocalNotification.StreakType> {
        self.hasSubmissions(userID: userID).then { hasSubmissions in
            self.fetchUserActivity(userID: userID).map { (hasSubmissions, $0) }
        }.then { hasSubmissions, userActivity -> Guarantee<StreakLocalNotification.StreakType> in
            guard let userActivity = userActivity else {
                return .value(hasSubmissions ? .notSolvedToday : .zero)
            }

            if userActivity.didSolveToday {
                return .value(.solvedToday)
            } else if hasSubmissions {
                return .value(.notSolvedToday)
            } else {
                return .value(.zero)
            }
        }
    }
}

final class NewProfileStreakNotificationsProvider: NewProfileStreakNotificationsProviderProtocol {
    private let submissionsPersistenceService: SubmissionsPersistenceServiceProtocol
    private let userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol

    init(
        submissionsPersistenceService: SubmissionsPersistenceServiceProtocol,
        userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol
    ) {
        self.submissionsPersistenceService = submissionsPersistenceService
        self.userActivitiesPersistenceService = userActivitiesPersistenceService
    }

    func hasSubmissions(userID: User.IdType) -> Guarantee<Bool> {
        self.submissionsPersistenceService.hasSubmissions(userID: userID)
    }

    func fetchUserActivity(userID: User.IdType) -> Guarantee<UserActivity?> {
        self.userActivitiesPersistenceService.fetch(id: userID).map(\.?.plainObject)
    }
}
