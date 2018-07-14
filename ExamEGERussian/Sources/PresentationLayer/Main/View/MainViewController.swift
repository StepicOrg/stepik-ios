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

    private let userRegistrationService: UserRegistrationService

    // MARK: Init

    init(userRegistrationService: UserRegistrationService) {
        self.userRegistrationService = userRegistrationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        checkAccessToken()
    }

    // MARK: Private API

    private func checkAccessToken() {
        checkToken().done { [weak self] in
            if !AuthInfo.shared.isAuthorized {
                self?.userRegistrationService
                    .registerNewUser()
                    .done { print($0) }
                    .catch { print($0) }
            }
        }.catch { print($0) }
    }

}
