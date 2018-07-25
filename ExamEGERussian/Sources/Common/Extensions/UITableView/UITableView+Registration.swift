//
//  UITableView+Registration.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension UITableView {
    func registerNib(for cellClass: UITableViewCell.Type) {
        register(cellClass.nib, forCellReuseIdentifier: cellClass.identifier)
    }

    func registerHeaderNib(for headerClass: UITableViewHeaderFooterView.Type) {
        register(headerClass.nib, forHeaderFooterViewReuseIdentifier: headerClass.identifier)
    }

    func registerClass(for cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
}
