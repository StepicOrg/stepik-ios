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
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLeadingConstraint: NSLayoutConstraint!
    
    var hasSeparator: Bool = false {
        didSet {
            separatorView?.hidden = !hasSeparator
        }
    }
    
    var separatorType: SeparatorType = .None {
        didSet {
            switch separatorType {
            case .None:
                hasSeparator = false
                separatorHeightConstraint.constant = 0
                break
            case .Small:
                hasSeparator = true
                separatorHeightConstraint.constant = 0.5
                separatorLeadingConstraint.constant = 8
                break
            case .Big:
                hasSeparator = true
                separatorHeightConstraint.constant = 10
                separatorLeadingConstraint.constant = -8
                break
            }
            updateConstraints()
        }
    }
    
    var comment: Comment?
    var heightUpdateBlock : (Void->Void)?
    
    func initWithComment(comment: Comment, user: UserInfo, separatorType: SeparatorType)  {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        self.comment = comment
        self.separatorType = separatorType
        
        timeLabel.text = comment.lastTime.getStepicFormatString()
        htmlContentView.loadHTMLText(comment.text)
    }
    
    private func setLeadingConstraints(constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        textContainerLeadingConstraint.constant = constant
        switch self.separatorType {
        case .Small: 
            separatorLeadingConstraint.constant = -constant + 8
            break
        default: 
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        htmlContentView.interactionDelegate = self        
        userAvatarImageView.setRoundedBounds(width: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comment = nil
        updateConstraints()
        htmlContentView.prepareForReuse()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        setLeadingConstraints(comment?.parentId == nil ? 0 : -40)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension DiscussionTableViewCell: HTMLContentViewInteractionDelegate {
    func shouldUpdateSize() {
        updateConstraints()
//        heightUpdateBlock?()
    }
}
