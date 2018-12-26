//
//  SplitTestGroupsListTests.swift
//  StepicTests
//
//  Created by Ivan Magda on 12/24/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import Quick

@testable import Stepic

final class SplitTestMock: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "split_test_mock"
    static let minParticipatingStartVersion = "1.74"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol {
        case control
        case test

        static var groups: [Group] = [.control, .test]
    }
}

final class ActiveSplitTestInfoProviderMock: ActiveSplitTestInfoProvider {
    var activeSplitTestInfos: [UniqueIdentifierType : SplitTestInfo] {
        return [
            SplitTestMock.identifier : SplitTestInfo(SplitTestMock.self)
        ]
    }
}

class SplitTestGroupsListSpec: QuickSpec {
    private func makeModule() -> SplitTestGroupsListViewController {
        let provider = SplitTestGroupsListProvider(
            splitTestInfoProvider: ActiveSplitTestInfoProviderMock(),
            storage: UserDefaults.standard
        )
        let presenter = SplitTestGroupsListPresenter()
        let interactor = SplitTestGroupsListInteractor(
            presenter: presenter,
            provider: provider,
            splitTestUniqueIdentifier: SplitTestMock.identifier
        )
        let viewController = SplitTestGroupsListViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }

    override func spec() {
        describe("SplitTestGroupsList") {
            var splitTestingService: SplitTestingService!
            var viewController: SplitTestGroupsListViewController!
            var splitTest: SplitTestMock!

            beforeEach {
                splitTestingService = SplitTestingService(
                    analyticsService: AnalyticsUserProperties(),
                    storage: UserDefaults.standard
                )

                splitTest = splitTestingService.fetchSplitTest(SplitTestMock.self)

                viewController = self.makeModule()
                viewController.loadViewIfNeeded()
            }

            it("Displays correct current selected group") {
                viewController.interactor.getGroups(request: .init())

                switch viewController.state {
                case .emptyResult:
                    fail("should contains groups")
                case .result(let data):
                    expect(data.count) == SplitTestMock.Group.groups.count

                    let viewModel = data.first(where: { $0.isChecked })!
                    expect(viewModel.uniqueIdentifier) == splitTest.currentGroup.rawValue
                }
            }

            it("Correctly changes split test group") {
                let currentGroup = splitTest.currentGroup
                let newGroup = SplitTestMock.Group.groups
                    .first(where: { $0.rawValue != currentGroup.rawValue })!

                viewController.interactor.selectGroup(
                    request: .init(viewModelUniqueIdentifier: newGroup.rawValue)
                )

                switch viewController.state {
                case .emptyResult:
                    fail("should contains groups")
                case .result(let data):
                    let selected = data.first(where: { $0.isChecked })!
                    expect(selected.uniqueIdentifier) == newGroup.rawValue

                    let splitTest = splitTestingService.fetchSplitTest(SplitTestMock.self)
                    expect(splitTest.currentGroup.rawValue) == newGroup.rawValue
                }
            }
        }
    }
}
