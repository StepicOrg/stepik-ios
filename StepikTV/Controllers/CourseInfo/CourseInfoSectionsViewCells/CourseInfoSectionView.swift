//
//  CourseInfoSectionCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoSectionView {

    static var size: CGSize { get }
    static var reuseIdentifier: String { get }

    func setup(with section: CourseInfoSection)
}
