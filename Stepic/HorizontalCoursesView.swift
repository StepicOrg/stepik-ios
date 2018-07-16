//
//  HorizontalCoursesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

class HorizontalCoursesView: NibInitializableView {

    @IBOutlet weak internal var titleLabel: StepikLabel!

    @IBOutlet weak internal var showAllButton: UIButton!

    @IBOutlet weak internal var courseCountLabel: StepikLabel!

    @IBOutlet weak internal var courseListContainerView: UIView!
    @IBOutlet weak var courseListContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var courseListDescriptionView: CourseListEmptyPlaceholder!
//    @IBOutlet weak var courseListDescriptionHeight: NSLayoutConstraint!

    @IBOutlet weak var titleDescriptionSpacing: NSLayoutConstraint!

    let courseListHeight: CGFloat = 290
    let courseListPlaceholderHeight: CGFloat = 104

    private var showVerticalBlock: ((Int?) -> Void)?

    override var nibName: String {
        return "HorizontalCoursesView"
    }

    var courseCount: Int = 0 {
        didSet {
            let pluralizedCountString = StringHelper.pluralize(number: courseCount, forms: [
                NSLocalizedString("courses1", comment: ""),
                NSLocalizedString("courses234", comment: ""),
                NSLocalizedString("courses567890", comment: "")
            ])
            courseCountLabel.text = courseCount == 0 || !shouldShowCount ? "" : "\(courseCount) \(pluralizedCountString)"
            showAllButton.isHidden = courseCount == 0
        }
    }

    var listDescription: String? {
        didSet {
            if let listDescription = listDescription {
                self.courseListDescriptionView.presentationStyle = .bordered
                self.courseListDescriptionView.text = listDescription
//                self.courseListDescriptionHeight.constant = courseListPlaceholderHeight
                self.titleDescriptionSpacing.constant = 16
            } else {
                self.courseListDescriptionView.snp.makeConstraints { $0.height.equalTo(0) }
//                self.courseListDescriptionHeight.constant = 0
                self.titleDescriptionSpacing.constant = 0
            }
        }
    }

    var shouldShowCount: Bool = false

    @IBAction func showAllPressed(_ sender: Any) {
        showVerticalBlock?(shouldShowCount ? courseCount : nil)
    }

    func setup(block: CourseListBlock) {
        self.listDescription = block.description
        self.showVerticalBlock = block.showVerticalBlock
        self.courseListDescriptionView.colorStyle = block.colorStyle
        showAllButton.setTitle(NSLocalizedString("ShowAll", comment: ""), for: .normal)
        block.horizontalController.changedPlaceholderVisibleBlock = {
            [weak self]
            visible in
            guard let strongSelf = self else {
                return
            }
            strongSelf.courseListContainerHeight.constant = visible ? strongSelf.courseListPlaceholderHeight : strongSelf.courseListHeight
        }
        titleLabel.text = block.title
        shouldShowCount = block.shouldShowCount
        courseCountLabel.colorMode = .gray
        courseCountLabel.isHidden = !shouldShowCount
        courseListContainerView.addSubview(block.horizontalController.view)
        block.horizontalController.view.snp.makeConstraints { $0.edges.equalTo(courseListContainerView) }
        showAllButton.setTitleColor(UIColor.lightGray, for: .normal)
        switch block.colorMode {
        case .dark:
            view.backgroundColor = UIColor.mainDark
            titleLabel.colorMode = .light
        case .light:
            view.backgroundColor = UIColor.white
            titleLabel.colorMode = .dark
        }
    }

    override func setupSubviews() {

    }
}
