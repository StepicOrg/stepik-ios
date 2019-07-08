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

final class DiscussionTableViewCell: UITableViewCell, Reusable, NibLoadable {
    @IBOutlet weak var userAvatarImageView: AvatarImageView!
    @IBOutlet weak var userAvatarImageViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var commentLabel: StepikLabel!
    @IBOutlet weak var commentLabelLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var nameLabel: StepikLabel!
    @IBOutlet weak var badgeLabel: WiderLabel!
    @IBOutlet weak var timeLabel: StepikLabel!
    @IBOutlet weak var likesLabel: StepikLabel!
    @IBOutlet weak var likesImageView: UIImageView!

    var comment: Comment?
    
    var onProfileButtonClick: ((Int) -> Void)?

    private var hasSeparator: Bool = false {
        didSet {
            self.separatorView.isHidden = !self.hasSeparator
        }
    }

    private var separatorType: DiscussionsViewData.SeparatorType = .none {
        didSet {
            switch self.separatorType {
            case .none:
                self.hasSeparator = false
                self.separatorViewHeightConstraint.constant = 0
            case .small:
                self.hasSeparator = true
                self.separatorViewHeightConstraint.constant = 0.5
                self.separatorViewLeadingConstraint.constant = 8
            case .big:
                self.hasSeparator = true
                self.separatorViewHeightConstraint.constant = 10
                self.separatorViewLeadingConstraint.constant = -8
            }
            self.updateConstraints()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.badgeLabel.setRoundedCorners(cornerRadius: 10)

        self.nameLabel?.isUserInteractionEnabled = true
        self.nameLabel?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.actionUserTapped))
        )

        self.userAvatarImageView?.isUserInteractionEnabled = true
        self.userAvatarImageView?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.actionUserTapped))
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.comment = nil
        self.updateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()
        self.setLeadingConstraints(self.comment?.parentId == nil ? 0 : -40)
    }

    func configure(viewData: DiscussionsViewData) {
        guard let comment = viewData.comment else {
            return
        }

        if let url = URL(string: comment.userInfo.avatarURL) {
            self.userAvatarImageView.set(with: url)
        }

        self.nameLabel.text = "\(comment.userInfo.firstName) \(comment.userInfo.lastName)"
        self.comment = comment
        self.separatorType = viewData.separatorType
        self.timeLabel.text = comment.time.getStepicFormatString(withTime: true)
        self.setLiked(comment.vote.value == .epic, likesCount: comment.epicCount)
        self.commentLabel.setTextWithHTMLString(comment.text)

        if comment.isDeleted {
            self.contentView.backgroundColor = .wrongQuizBackground
            if comment.text == "" {
                self.commentLabel.text = NSLocalizedString("DeletedComment", comment: "")
            }
        } else {
            self.contentView.backgroundColor = .white
        }

        switch comment.userRole {
        case .student:
            self.badgeLabel.text = ""
            self.badgeLabel.backgroundColor = .clear
        case .teacher:
            self.badgeLabel.text = NSLocalizedString("CourseStaff", comment: "")
            self.badgeLabel.backgroundColor = .lightGray
        case .staff:
            self.badgeLabel.text = NSLocalizedString("Staff", comment: "")
            self.badgeLabel.backgroundColor = .lightGray
        }
    }

    private func setLiked(_ liked: Bool, likesCount: Int) {
        self.likesLabel.text = "\(likesCount)"
        if liked {
            self.likesImageView.image = Images.thumbsUp.filled
        } else {
            self.likesImageView.image = Images.thumbsUp.normal
        }
    }

    private func setLeadingConstraints(_ constant: CGFloat) {
        self.userAvatarImageViewLeadingConstraint.constant = constant
        self.commentLabelLeadingConstraint.constant = -constant

        switch self.separatorType {
        case .small:
            self.separatorViewLeadingConstraint.constant = -constant
        default:
            break
        }
    }

    @objc
    private func actionUserTapped() {
        if let userId = self.comment?.userInfo.id {
            self.onProfileButtonClick?(userId)
        }
    }
}
