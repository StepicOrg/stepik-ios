//
//  ShareableController.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol ShareableController {
    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool)
}
