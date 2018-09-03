//
//  ExploreViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ExploreViewController: UIViewController {
    override func loadView() {
        let view = ExploreView(frame: UIScreen.main.bounds)
        self.view = view
    }
}
