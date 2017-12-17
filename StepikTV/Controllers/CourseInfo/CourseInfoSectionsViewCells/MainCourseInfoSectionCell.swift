//
//  MainCourseInfoCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MainCourseInfoSectionCell: UICollectionViewCell, CourseInfoSectionView {
    static var reuseIdentifier: String { return "MainCourseInfoSectionCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 787.0) }

    @IBOutlet var title: UILabel!
    @IBOutlet var hosts: UILabel!
    @IBOutlet var descr: UILabel!
    @IBOutlet var leftIconButton: IconButton!
    @IBOutlet var rightIconButton: IconButton!
    @IBOutlet var imageView: UIImageView!

    func setup(with section: CourseInfoSection) {
        title.text = section.title

        switch section.contentType {
        case let .main(hosts: hosts, descr: descr, imageURL: imageURL, introVideo: introURL, subscriptionAction: action):
            self.hosts.text = hosts[0]
            self.descr.text = descr
            imageView.setImageWithURL(url: imageURL, placeholder: #imageLiteral(resourceName: "placeholder"))
        default:
            fatalError("Sections data and view dependencies fails")
        }
    }
}
