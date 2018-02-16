//
//  CourseListEmptyPlaceholder.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseListEmptyPlaceholder: NibInitializableView {

    @IBOutlet weak var textLabel: StepikLabel!
    @IBOutlet weak var placeholderImageView: UIImageView!

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var countLabel: StepikLabel!
//    @IBOutlet weak var titleCenterVerticallyConstraint: NSLayoutConstraint!

    @IBOutlet weak var countHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionCountDistance: NSLayoutConstraint!

    var colorStyle: ColorStyle = .purple {
        didSet {
            updateColorStyle()
        }
    }

    var presentationStyle: PresentationStyle = .bordered {
        didSet {
            updatePresentationStyle()
        }
    }

    func updateTextAlignment() {
        switch presentationStyle {
        case .bordered:
            if textLabel.numberOfVisibleLines == 1 {
                textLabel.textAlignment = .center
            } else {
                textLabel.textAlignment = .natural
            }
        case .fullWidth:
            textLabel.textAlignment = .center
        }
        textLabel.layoutSubviews()
    }

    var text: String = "" {
        didSet {
            textLabel.setTextWithHTMLString(text)
            updateTextAlignment()
        }
    }

    var count: Int? {
        didSet {

            if let count = count {
                let pluralizedCountString = StringHelper.pluralize(number: count, forms: [
                    NSLocalizedString("courses1", comment: ""),
                    NSLocalizedString("courses234", comment: ""),
                    NSLocalizedString("courses567890", comment: "")
                    ])

                countLabel.text = "\(count) \(pluralizedCountString)"
                countHeight.constant = 17
                descriptionCountDistance.constant = 8
            } else {
                countHeight.constant = 0
                descriptionCountDistance.constant = 0
            }
            self.view.layoutSubviews()
        }
    }

    var onTap: (() -> Void)?

    override var nibName: String {
        return "CourseListEmptyPlaceholder"
    }

    func updateColorStyle() {
        textLabel.textColor = colorStyle.textColor
        placeholderImageView.image = colorStyle.image
    }

    func updatePresentationStyle() {
        leadingConstraint.constant = presentationStyle.insets.left
        trailingConstraint.constant = presentationStyle.insets.right
        bottomConstraint.constant = presentationStyle.insets.bottom
        topConstraint.constant = presentationStyle.insets.top
        contentView.setRoundedCorners(cornerRadius: presentationStyle.cornerRadius)
        updateTextAlignment()
        if presentationStyle == .bordered {
            count = nil
        }
    }

    override func setupSubviews() {
        let tapG = UITapGestureRecognizer(target: self, action: #selector(CourseListEmptyPlaceholder.didTap(touch:)))
        contentView.addGestureRecognizer(tapG)
        updateColorStyle()
        updatePresentationStyle()
    }

    @objc func didTap(touch: UITapGestureRecognizer) {
        onTap?()
    }

    enum ColorStyle {
        case purple, blue, pink

        var image: UIImage {
            switch self {
            case .purple:
                return #imageLiteral(resourceName: "course_list_purple_placeholder")
            case .blue:
                return #imageLiteral(resourceName: "courses_gradient_blue")
            case .pink:
                return #imageLiteral(resourceName: "courses_gradient_pink")
            }
        }

        var textColor: UIColor {
            switch self {
            case .purple:
                return UIColor.white
            case .blue:
                return UIColor(hex: 0x00484E)
            case .pink:
                return UIColor(hex: 0x18073D)
            }
        }

        static var randomPositiveStyle: ColorStyle {
            let variations: [ColorStyle] = [.blue, .pink]
            let randomIndex = Int(arc4random_uniform(UInt32(variations.count)))
            return variations[randomIndex]
        }
    }

    enum PresentationStyle {
        case bordered, fullWidth

        var insets: UIEdgeInsets {
            switch self {
            case .bordered:
                return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            case .fullWidth:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .bordered:
                return 8
            case .fullWidth:
                return 0
            }
        }
    }
}
