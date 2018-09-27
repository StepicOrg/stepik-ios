//
//  HomeHomePresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomePresenterProtocol: ExplorePresenterProtocol {
    func presentStreakActivity(response: Home.LoadStreak.Response)
}

final class HomePresenter: ExplorePresenter, HomePresenterProtocol {
    lazy var homeViewController = self.viewController as? HomeViewControllerProtocol

    func presentStreakActivity(response: Home.LoadStreak.Response) {
        var viewModel: Home.LoadStreak.ViewModel

        switch response.result {
        case .hidden:
            viewModel = .init(result: .hidden)
        case .success(let currentStreak, let needsToSolveToday):
            if currentStreak > 0 {
                viewModel = .init(
                    result: .visible(
                        message: self.makeStreakActivityMessage(
                            days: currentStreak,
                            needsToSolveToday: needsToSolveToday
                        ),
                        streak: currentStreak
                    )
                )
            } else {
                viewModel = .init(result: .hidden)
            }
        }

        self.homeViewController?.displayStreakInfo(viewModel: viewModel)
    }

    private func makeStreakActivityMessage(days: Int, needsToSolveToday: Bool) -> String {
        let pluralizedDaysCnt = StringHelper.pluralize(
            number: days,
            forms: [
                NSLocalizedString("days1", comment: ""),
                NSLocalizedString("days234", comment: ""),
                NSLocalizedString("days567890", comment: "")
            ]
        )
        var countText = String(
            format: NSLocalizedString("SolveStreaksDaysCount", comment: ""),
            "\(days)",
            "\(pluralizedDaysCnt)"
        )

        if needsToSolveToday {
            countText += "\n\(NSLocalizedString("SolveSomethingToday", comment: ""))"
        }

        return countText
    }

    // MARK: - ExplorePresenter

    override func presentLanguageSwitchBlock(
        response: Explore.CheckLanguageSwitchAvailability.Response
    ) {
        // Always hide language switch for Home
        self.viewController?.displayLanguageSwitchBlock(viewModel: .init(isHidden: true))
    }

}
