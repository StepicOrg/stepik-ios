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

    static func getHeightForCell(section: CourseInfoSection, width: CGFloat) -> CGFloat {
        guard case let .main(hosts: _, descr: descr, imageURL: _, trailerAction: _, subscriptionAction: _, selectionAction: _) = section.contentType else {
            return 35.0
        }

        let titleHeight = max(69.0, UILabel.heightForLabelWithText(section.title, lines: 0, font: UIFont.systemFont(ofSize: 57, weight: UIFontWeightMedium), width: width - 1000, alignment: .left))

        let hostsHeight = CGFloat(46.0)

        var contentHeight = UILabel.heightForLabelWithText(descr, lines: 0, font: UIFont.systemFont(ofSize: 29, weight: UIFontWeightRegular), width: width - 1000, alignment: .left)
            contentHeight = contentHeight > 350.0 ? 350.0 : contentHeight

        return (titleHeight + hostsHeight + contentHeight + 300.0)
    }

    @IBOutlet var title: UILabel!
    @IBOutlet var hosts: UILabel!
    @IBOutlet var descr: TVFocusableText!
    @IBOutlet var leftIconButton: IconButton!
    @IBOutlet var rightIconButton: IconButton!
    @IBOutlet var imageView: UIImageView!

    var trailerAction : (() -> Void)?
    func pressedVideoButton(_ sender: UIButton) {
        trailerAction?()
    }

    private let introTitle: String = NSLocalizedString("Intro", comment: "")
    private let subscribeTitle: String = NSLocalizedString("Subscribe", comment: "")

    func setup(with section: CourseInfoSection) {
        title.text = section.title

        switch section.contentType {
        case let .main(hosts: _, descr: descr, imageURL: imageURL, trailerAction: trailerAction, subscriptionAction: _, selectionAction: selectionAction):
            self.hosts.text = "To do..."
            self.descr.setTextWithHTMLString(descr)
            self.descr.pressAction = selectionAction
            self.imageView.setImageWithURL(url: imageURL, placeholder: #imageLiteral(resourceName: "placeholder"))
            self.trailerAction = trailerAction
            self.leftIconButton.configure(with: #imageLiteral(resourceName: "intro_icon"), introTitle)
            self.rightIconButton.configure(with: #imageLiteral(resourceName: "subscribe_icon"), subscribeTitle)
            self.leftIconButton.button.addTarget(self, action: #selector(pressedVideoButton(_:)), for: .primaryActionTriggered)
        default:
            fatalError("Sections data and view dependencies fails")
        }
    }
}
