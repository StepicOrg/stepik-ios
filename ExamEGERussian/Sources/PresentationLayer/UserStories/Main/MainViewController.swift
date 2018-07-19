//
//  MainViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import PromiseKit

// MARK: MainViewController: UIViewController

final class MainViewController: UIViewController {

    // MARK: - Instance Properties

    var userRegistrationService: UserRegistrationService?

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(userRegistrationService != nil, "UserRegistrationService must be initialized")

        checkAccessToken()

        GraphServiceImpl().obtainGraph { result in
            switch result {
            case .success(let responseData):
                print(responseData)
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: Private API

    private func checkAccessToken() {
        checkToken().done { [weak self] in
            if !AuthInfo.shared.isAuthorized {
                self?.userRegistrationService?
                    .registerNewUser()
                    .done { print($0) }
                    .catch { print($0) }
            }
        }.catch { print($0) }
    }

}
