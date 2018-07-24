//
//  UITableViewCell+ReusableCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

import UIKit

protocol ReusableCell {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension UITableViewCell: ReusableCell {
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
