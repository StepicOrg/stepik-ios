//
//  DiscussionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

protocol DiscussionTableViewCellDelegate: class {
    func didOpenProfile(for userWithId: Int)
}

class DiscussionTableViewCell: UITableViewCell {
    weak var delegate: DiscussionTableViewCellDelegate?

    @IBOutlet weak var userAvatarImageView: AvatarImageView!
    @IBOutlet weak var nameLabel: StepikLabel!

    @IBOutlet weak var badgeLabel: WiderLabel!

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var timeLabel: StepikLabel!

    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var ImageLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var likesLabel: StepikLabel!
    @IBOutlet weak var likesImageView: UIImageView!

    @IBOutlet weak var labelContainerView: UIView!
    var commentLabel: StepikLabel?

    var hasSeparator: Bool = false {
        didSet {
            separatorView?.isHidden = !hasSeparator
        }
    }

    var separatorType: SeparatorType = .none {
        didSet {
            switch separatorType {
            case .none:
                hasSeparator = false
                separatorHeightConstraint.constant = 0
                break
            case .small:
                hasSeparator = true
                separatorHeightConstraint.constant = 0.5
                separatorLeadingConstraint.constant = 8
                break
            case .big:
                hasSeparator = true
                separatorHeightConstraint.constant = 10
                separatorLeadingConstraint.constant = -8
                break
            }
            updateConstraints()
        }
    }

    var comment: Comment?
    var heightUpdateBlock : (() -> Void)?

    func initWithComment(_ comment: Comment, separatorType: SeparatorType) {
        if let url = URL(string: comment.userInfo.avatarURL) {
            userAvatarImageView.set(with: url)
        }

        nameLabel.text = "\(comment.userInfo.firstName) \(comment.userInfo.lastName)"
        self.comment = comment
        self.separatorType = separatorType
        labelContainerView.backgroundColor = UIColor.clear
        timeLabel.text = comment.time.getStepicFormatString(withTime: true)
        setLiked(comment.vote.value == .Epic, likesCount: comment.epicCount)
        loadLabel(comment.text)
        if comment.isDeleted {
            self.contentView.backgroundColor = UIColor.wrongQuizBackground
            if comment.text == "" {
                loadLabel(NSLocalizedString("DeletedComment", comment: ""))
            }
        } else {
            self.contentView.backgroundColor = UIColor.white
        }

        switch comment.userRole {
        case .Student:
            badgeLabel.text = ""
            badgeLabel.backgroundColor = UIColor.clear
        case .Teacher:
            badgeLabel.text = NSLocalizedString("CourseStaff", comment: "")
            badgeLabel.backgroundColor = UIColor.lightGray
        case .Staff:
            badgeLabel.text = NSLocalizedString("Staff", comment: "")
            badgeLabel.backgroundColor = UIColor.lightGray
        }
    }

    fileprivate func constructLabel() {
        commentLabel = StepikLabel()
        labelContainerView.addSubview(commentLabel!)
        commentLabel?.snp.makeConstraints { $0.edges.equalTo(labelContainerView) }
        commentLabel?.numberOfLines = 0
    }

    fileprivate func loadLabel(_ htmlString: String) {
        let wrapped = HTMLProcessor.shared.process(htmlString: htmlString)
        if let data = wrapped.data(using: String.Encoding.unicode, allowLossyConversion: false) {
            do {
                let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).attributedStringByTrimmingNewlines()
                commentLabel?.attributedText = attributedString
                layoutSubviews()
                updateConstraints()
                commentLabel?.textColor = UIColor.mainText
            } catch {
                //TODO: throw an exception here, or pass an error
            }
        }
    }

    fileprivate func setLeadingConstraints(_ constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        labelLeadingConstraint.constant = constant
        switch self.separatorType {
        case .small:
            separatorLeadingConstraint.constant = -constant
            break
        default:
            break
        }
    }

    func setLiked(_ liked: Bool, likesCount: Int) {
        likesLabel.text = "\(likesCount)"
        if liked {
            likesImageView.image = Images.thumbsUp.filled
        } else {
            likesImageView.image = Images.thumbsUp.normal
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        constructLabel()
        badgeLabel.setRoundedCorners(cornerRadius: 10)

        let tapActionNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.actionUserTapped))
        nameLabel?.isUserInteractionEnabled = true
        nameLabel?.addGestureRecognizer(tapActionNameLabel)

        let tapActionAvatarView = UITapGestureRecognizer(target: self, action: #selector(self.actionUserTapped))
        userAvatarImageView?.isUserInteractionEnabled = true
        userAvatarImageView?.addGestureRecognizer(tapActionAvatarView)
    }

    @objc func actionUserTapped() {
        guard let userId = comment?.userInfo.id else {
            return
        }

        delegate?.didOpenProfile(for: userId)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
