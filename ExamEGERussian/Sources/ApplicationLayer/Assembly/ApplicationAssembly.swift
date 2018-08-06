//
//  ApplicationAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UIViewController

struct ApplicationModule {
    var router: AppRouter?
    weak var rootViewController: UIViewController? {
        return router?.window?.rootViewController
    }

    init(router: AppRouter) {
        self.router = router
    }
}

protocol ApplicationAssembly: class {
    func module() -> ApplicationModule
}
