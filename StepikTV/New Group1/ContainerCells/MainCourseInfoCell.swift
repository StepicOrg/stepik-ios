//
//  MainCourseInfoCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MainCourseInfoCell: UICollectionViewCell, DynamicallyCreatedProtocol, ItemConfigurableProtocol {

    static var reuseIdentifier: String { get { return "MainCourseInfoCell" } }

    static var size: CGSize { get { return CGSize(width: UIScreen.main.bounds.width, height: 787.0) } }

    @IBOutlet var courseImageView: UIImageView!

    @IBOutlet var courseTitle: UILabel!

    @IBOutlet var courseHost: UILabel!

    @IBOutlet var courseDescription: UILabel!

    @IBOutlet var leftIconButton: IconButton!

    @IBOutlet var rightIconButton: IconButton!

    private var course: CourseMock?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with data: CourseMock) {
        course = data

        courseTitle.text = course?.name
        courseHost.text = course?.host
        courseImageView.image = course?.image
    }

}
