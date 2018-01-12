//
//  MainCourseInfoCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MainCourseInfoSectionCell: UICollectionViewCell, CourseInfoSectionViewProtocol {
    static var nibName: String { return "MainCourseInfoSectionCell" }
    static var reuseIdentifier: String { return "MainCourseInfoSectionCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 787.0) }

    @IBOutlet var title: UILabel!
    @IBOutlet var hosts: UILabel!
    @IBOutlet var descr: TVFocusableText!
    @IBOutlet var leftIconButton: IconButton!
    @IBOutlet var rightIconButton: IconButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint.constant = MainCourseInfoSectionCell.size.width
    }

    func setup(with section: CourseInfoSection) {
        title.text = section.title

        switch section.contentType {
        case let .main(hosts: hosts, descr: descr, imageURL: imageURL, trailerAction: _, subscriptionAction: _, selectionAction: selectionAction):
            self.hosts.text = hosts[0]
            self.descr.setTextWithHTMLString(descr)
            self.descr.pressAction = selectionAction
            imageView.setImageWithURL(url: imageURL, placeholder: #imageLiteral(resourceName: "placeholder"))
        default:
            fatalError("Sections data and view dependencies fails")
        }
    }
}
