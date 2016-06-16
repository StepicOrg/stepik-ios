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
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var ImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerLeadingConstraint: NSLayoutConstraint!
    
    var hasSeparator: Bool = false {
        didSet {
            separatorView?.hidden = !hasSeparator
        }
    }
    
    var commentLabel: UILabel! = UILabel()
    var commentWebView: UIWebView! = UIWebView()
    
    var webViewHelper : CellWebViewHelper!
    weak var delegate : DiscussionCellDelegate?
    var indexPath: NSIndexPath!
    
    func initLabel() {
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont(name: "ArialMT", size: 14)
        commentLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        commentLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        commentLabel.textAlignment = NSTextAlignment.Natural
        commentLabel.backgroundColor = UIColor.clearColor()
        textContainerView.addSubview(commentLabel)
        commentLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", toView: textContainerView)
        commentLabel.hidden = true
    }
    
    func initWithComment(comment: Comment, user: UserInfo) -> (Void -> Int)? {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if comment.parentId != nil {
            setLeadingConstraints(-40)
        }
        timeLabel.text = comment.lastTime.getStepicFormatString()
        
//        if TagDetectionUtil.isWebViewSupportNeeded(comment.text) {
//            commentWebView.hidden = false
//            return webViewHelper.setTextWithTeX(comment.text)
//        } else {
            commentLabel.hidden = false
            commentLabel.setTextWithHTMLString(comment.text)
//        }
        return nil
    }
    
    private func setLeadingConstraints(constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        textContainerLeadingConstraint.constant = constant

    }
    
    func initWebView() {
        textContainerView.addSubview(commentWebView)
        commentWebView.alignToView(textContainerView)
        webViewHelper = CellWebViewHelper(webView: commentWebView, heightWithoutWebView: 70)
        commentWebView.hidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        textContainerView.backgroundColor = UIColor.clearColor()
        let tapG = UITapGestureRecognizer()
        tapG.numberOfTapsRequired = 1
        tapG.addTarget(self, action: #selector(DiscussionTableViewCell.didTap(_:)))
        self.contentView.addGestureRecognizer(tapG)
        
        initLabel()
        initWebView()
    }
    
    func didTap(g: UITapGestureRecognizer) {
        setHighlighted(true, animated: true)
        delegate?.didSelect(indexPath, deselectBlock: {
            [weak self] in
            self?.setHighlighted(false, animated: true)
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentWebView.hidden = true
        commentLabel.hidden = true
        setLeadingConstraints(0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    class func estimatedHeightForTextWithComment(comment: Comment) -> Int {
        var width: CGFloat = 16
        if comment.parentId != nil {
            width += 40
        }
        
        return max(27, Int(UILabel.heightForLabelWithText(comment.text, lines: 0, fontName: "ArialMT", fontSize: 14, width: UIScreen.mainScreen().bounds.width - width))) + 80
    }
}

//extension DiscussionTableViewCell : TextHeightDependentCellProtocol {
//    
//    //All optimization logics is now encapsulated here
//    func setHTMLText(text: String) -> (Void -> Int) {
//        if TagDetectionUtil.isWebViewSupportNeeded(text) {
//            commentWebView.hidden = false
//            return webViewHelper.setTextWithTeX(text)
//        } else {
//            commentLabel.hidden = false
//            commentLabel.setTextWithHTMLString(text)
//            let w = textContainerView.bounds.width 
//            return {
//                return 0
//            }
//        }
//    }
//}