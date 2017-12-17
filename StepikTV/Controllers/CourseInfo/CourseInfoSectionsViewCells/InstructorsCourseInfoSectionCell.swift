//
//  InstructorsCourseInfoSectionCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class InstructorsCourseInfoSectionCell: UICollectionViewCell, CourseInfoSectionView {
    static var reuseIdentifier: String { return "InstructorsCourseInfoSectionCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 300.0) }

    func setup(with section: CourseInfoSection) {
        //...
    }

    //...
}
