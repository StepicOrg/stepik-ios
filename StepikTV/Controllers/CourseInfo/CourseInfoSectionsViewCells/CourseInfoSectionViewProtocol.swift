//
//  CourseInfoSectionCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoSectionViewProtocol {
    static var nibName: String { get }
    static var size: CGSize { get }
    static var reuseIdentifier: String { get }

    static func getHeightForCell(section: CourseInfoSection, width: CGFloat) -> CGFloat

    func setup(with section: CourseInfoSection)
}
