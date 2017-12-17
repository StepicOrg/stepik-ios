//
//  DetailsCourseInfoCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class DetailsCourseInfoCell: UICollectionViewCell, DynamicallyCreatedProtocol {

    static var reuseIdentifier: String { get { return "MainCourseInfoCell" } }

    static var size: CGSize { get { return CGSize(width: UIScreen.main.bounds.width, height: 300.0) } }

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var contentLabel: UILabel!

    func configure(with title: String, _ content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }

}
