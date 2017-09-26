//
//  NotificationsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, NotificationsView {
    var presenter: NotificationsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = NotificationsPresenter(view: self)
    }
}
