//
//  HomeHomeInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol HomeInteractorProtocol: ExploreInteractorProtocol {
    func loadStreakActivity(request: Home.LoadStreak.Request)
}

final class HomeInteractor: ExploreInteractor, HomeInteractorProtocol {
    let provider: HomeProviderProtocol
    private let userAccountService: UserAccountServiceProtocol

    lazy var homePresenter = self.presenter as? HomePresenterProtocol

    init(
        presenter: HomePresenterProtocol,
        provider: HomeProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol
    ) {
        self.provider = provider
        self.userAccountService = userAccountService
        super.init(
            presenter: presenter,
            contentLanguageService: contentLanguageService,
            languageSwitchAvailabilityService: languageSwitchAvailabilityService
        )
    }

    func loadStreakActivity(request: Home.LoadStreak.Request) {
        guard let user = self.userAccountService.currentUser else {
            self.homePresenter?.presentStreakActivity(response: .init(result: .hidden))
            return
        }

        self.provider.fetchUserActivity(user: user).done { activity in
            self.homePresenter?.presentStreakActivity(
                response: .init(
                    result: .success(
                        currentStreak: activity.currentStreak,
                        needsToSolveToday: activity.needsToSolveToday
                    )
                )
            )
        }.catch { _ in
            self.homePresenter?.presentStreakActivity(response: .init(result: .hidden))
        }
    }
}
