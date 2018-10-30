//
//  CourseInfoViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let styledNavigationController = self.navigationController
            as? StyledNavigationViewController {
            styledNavigationController.changeNavigationBarAlpha(0.0)
            styledNavigationController.changeShadowAlpha(0.0)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let styledNavigationController = self.navigationController
            as? StyledNavigationViewController {
            styledNavigationController.changeNavigationBarAlpha(1.0)
            styledNavigationController.changeShadowAlpha(1.0)
        }

        super.viewWillDisappear(animated)
    }

    override func loadView() {
        let view = CourseInfoView(frame: UIScreen.main.bounds)
        self.view = view
    }
}
