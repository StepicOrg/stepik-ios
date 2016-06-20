//
//  DiscussionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import SDWebImage

class DiscussionTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var ImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var htmlContentView: HTMLContentView!
    
    var hasSeparator: Bool = false {
        didSet {
            separatorView?.hidden = !hasSeparator
        }
    }
    var heightUpdateBlock : (Void->Void)?

    func initWithComment(comment: Comment, user: UserInfo)  {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
        userAvatarImageView.setRoundedBounds(width: 0)
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if comment.parentId != nil {
            setLeadingConstraints(-40)
        }
        timeLabel.text = comment.lastTime.getStepicFormatString()
        htmlContentView.interactionDelegate = self        
        htmlContentView.htmlText = comment.text
    }
    
    private func setLeadingConstraints(constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        textContainerLeadingConstraint.constant = constant
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setLeadingConstraints(0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension DiscussionTableViewCell: HTMLContentViewInteractionDelegate {
    func shouldUpdateSize() {
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
        heightUpdateBlock?()
    }
}
