//
//  MainAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class MainAssemblyImpl: BaseAssembly, MainAssembly {
    func module() -> UIViewController {
        let userRegistrationService = serviceFactory.userRegistrationService()

        return MainViewController(userRegistrationService: userRegistrationService)
    }
}
