//
//  RootNavigationManager.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

// MARK: RootNavigationManager

final class RootNavigationManager {
    
    // MARK: - Instance Variables
    
    private weak var mainViewController: MainViewController?
    private unowned let serviceComponents: ServiceComponents
    
    // MARK: Init
    
    init(with window: UIWindow?, serviceComponents: ServiceComponents) {
        guard let rootViewController = window?.rootViewController as? MainViewController else {
            fatalError("RootViewController should be MainViewController")
        }
        
        self.mainViewController = rootViewController
        self.serviceComponents = serviceComponents
    }
    
    // MARK: Public API
    
    func setup() {
        mainViewController?.userRegistrationService = serviceComponents.userRegistrationService
    }
    
}
