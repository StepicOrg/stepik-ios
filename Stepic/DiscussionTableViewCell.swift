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
    
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ImageLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    
    @IBOutlet weak var labelContainerView: UIView!
    var commentLabel: UILabel?
    
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

    func initWithComment(comment: Comment, separatorType: SeparatorType)  {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: comment.userInfo.avatarURL)!)
        nameLabel.text = "\(comment.userInfo.firstName) \(comment.userInfo.lastName)"
        self.comment = comment
        self.separatorType = separatorType
        
        timeLabel.text = comment.lastTime.getStepicFormatString(withTime: true)
        setLiked(comment.vote.value == .Epic, likesCount: comment.epicCount)
        loadLabel(comment.text)
    }
    
    private func constructLabel() {
        commentLabel = UILabel()
        labelContainerView.addSubview(commentLabel!)
        commentLabel?.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: labelContainerView)
        commentLabel?.numberOfLines = 0
    }
    
    private func loadLabel(htmlString: String) {
        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
        if let data = wrapped.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false) {
            do {
                let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil).attributedStringByTrimmingNewlines()
                commentLabel?.attributedText = attributedString
                layoutSubviews()
                updateConstraints()
            }
            catch {
                //TODO: throw an exception here, or pass an error
            }
        }
    }
    
    private func setLeadingConstraints(constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        labelLeadingConstraint.constant = constant
        switch self.separatorType {
        case .Small: 
            separatorLeadingConstraint.constant = -constant
            break
        default: 
            break
        }
    }
    
    func setLiked(liked: Bool, likesCount: Int) {
        likesLabel.text = "\(likesCount)"
        if liked {
            likesImageView.image = Images.thumbsUp.filled
        } else {
            likesImageView.image = Images.thumbsUp.normal
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarImageView.setRoundedBounds(width: 0)
        constructLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comment = nil
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        setLeadingConstraints(comment?.parentId == nil ? 0 : -40)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
