//
//  SocialAuthHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SocialAuthHeaderView: UICollectionReusableView {
    static let reuseId = "socialAuthHeaderView"

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let head = NSLocalizedString("SignInTitleHead", comment: "")
        let tail = NSLocalizedString("SignInTitleSocialTail", comment: "")
        let attributedString = NSMutableAttributedString(string: "\(head) \(tail)")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: head.characters.count))
        titleLabel.attributedText = attributedString
    }
}
