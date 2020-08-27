import UIKit

protocol NewProfileStreakNotificationsPresenterProtocol {
    func presentStreakNotifications(response: NewProfileStreakNotifications.StreakNotificationsLoad.Response)
    func presentSelectStreakNotificationsTime(
        response: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.Response
    )
    func presentTooltip(response: NewProfileStreakNotifications.TooltipAvailabilityCheck.Response)
}

final class NewProfileStreakNotificationsPresenter: NewProfileStreakNotificationsPresenterProtocol {
    weak var viewController: NewProfileStreakNotificationsViewControllerProtocol?

    func presentStreakNotifications(response: NewProfileStreakNotifications.StreakNotificationsLoad.Response) {
        let viewModel = self.makeViewModel(
            isStreakNotificationsEnabled: response.isStreakNotificationsEnabled,
            streaksNotificationsStartHour: response.streaksNotificationsStartHour
        )
        self.viewController?.displayStreakNotifications(viewModel: .init(viewModel: viewModel))
    }

    func presentSelectStreakNotificationsTime(
        response: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.Response
    ) {
        self.viewController?.displaySelectStreakNotificationsTime(viewModel: .init(startHour: response.startHour))
    }

    func presentTooltip(response: NewProfileStreakNotifications.TooltipAvailabilityCheck.Response) {
        self.viewController?.displayTooltip(viewModel: .init(shouldShowTooltip: response.shouldShowTooltip))
    }

    // MARK: Private API

    private func makeViewModel(
        isStreakNotificationsEnabled: Bool,
        streaksNotificationsStartHour: Int
    ) -> NewProfileStreakNotificationsViewModel {
        let streakNotificationsTime: String? = {
            guard isStreakNotificationsEnabled else {
                return nil
            }

            let startInterval = TimeInterval((streaksNotificationsStartHour % 24) * 60 * 60)
            let startDate = Date(timeIntervalSinceReferenceDate: startInterval)

            let endInterval = TimeInterval((streaksNotificationsStartHour + 1) % 24 * 60 * 60)
            let endDate = Date(timeIntervalSinceReferenceDate: endInterval)

            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none

            return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        }()

        let streakNotificationsUpdatingTime: String? = {
            guard isStreakNotificationsEnabled else {
                return nil
            }

            let date = Date(timeIntervalSince1970: 0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = TimeZone.current
            let currentZone00UTC = dateFormatter.string(from: date)

            let localizedZoneName = TimeZone.current.localizedName(for: .standard, locale: .current) ?? ""

            return "\(NSLocalizedString("StreaksAreUpdated", comment: "")) \(currentZone00UTC) \(localizedZoneName)."
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }()

        return NewProfileStreakNotificationsViewModel(
            isStreakNotificationsEnabled: isStreakNotificationsEnabled,
            formattedStreakNotificationsTime: streakNotificationsTime,
            formattedStreakNotificationsUpdatingTime: streakNotificationsUpdatingTime
        )
    }
}
