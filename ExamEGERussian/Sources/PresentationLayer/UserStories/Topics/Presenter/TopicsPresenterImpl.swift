//
//  TopicsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsPresenterImpl: TopicsPresenter {

    private weak var view: TopicsView?
    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphService

    var numberOfTopics: Int {
        return 10
    }

    init(view: TopicsView, userRegistrationService: UserRegistrationService, graphService: GraphService) {
        self.view = view
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func viewDidLoad() {
        checkAuthStatus()
        fetchGraphData()
    }

    func configure(cell: TopicCellView, forRow row: Int) {
        cell.display(title: "Title for row: \(row)")
    }

    func didSelect(row: Int) {
        print("\(#function) row: \(row)")
    }

    func titleForScene() -> String {
        return "Topics".localized
    }

    // MARK: - Private API

    private func checkAuthStatus() {
        if !AuthInfo.shared.isAuthorized {
            userRegistrationService.registerNewUser().done {
                print("Successfully register user with: \($0.id)")
            }.catch { [weak self] error in
                self?.displayError(error)
            }
        }
    }

    private func fetchGraphData() {
        graphService.obtainGraph { [weak self] result in
            switch result {
            case .success(let responseModel):
                print(responseModel)
            case .failure(let error):
                self?.displayError(error)
            }
        }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: "Error".localized, message: error.localizedDescription)
    }
}
