//
// Created by Ivan Magda on 2018-08-10.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

final class StepsPagerRouterImpl: BaseRouter, StepsPagerRouter {
    func shareStep(with url: String) {
        navigationController?.present(SharingHelper.getSharingController(url), animated: true)
    }
}
