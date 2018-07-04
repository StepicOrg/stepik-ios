//
//  ViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import PromiseKit

// MARK: ViewController: UIViewController

final class ViewController: UIViewController {
    
    // MARK: - Instance Properties

    private lazy var userRegistrationService: UserRegistrationService = {
        let userSubscriptionsService = UserSubscriptionsServiceImplementation(profilesAPI: ProfilesAPI())
        let userRegistrationService = UserRegistrationServiceImplementation(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            userSubscriptionsService: userSubscriptionsService,
            defaultsStorageManager: DefaultsStorageManager()
        )
        
        return userRegistrationService
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkToken().then { [weak self] _ -> Void in
            if !AuthInfo.shared.isAuthorized {
                _ = self?.userRegistrationService.registerNewUser()
            }
        }.catch { error in
            print(error)
        }
    }

}
