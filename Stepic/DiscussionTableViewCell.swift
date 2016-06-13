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
    
    var hasSeparator: Bool = false {
        didSet {
            separatorView?.hidden = !hasSeparator
        }
    }
    
    var commentLabel: UILabel! = UILabel()
    var commentWebView: UIWebView! = UIWebView()
    
    var webViewHelper : CellWebViewHelper!
    
    func initLabel() {
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont(name: "ArialMT", size: 16)
        commentLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        commentLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        commentLabel.textAlignment = NSTextAlignment.Natural
        commentLabel.backgroundColor = UIColor.clearColor()
        textContainerView.addSubview(commentLabel)
        commentLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", toView: textContainerView)
        commentLabel.hidden = true
    }
    
    func initWithComment(comment: Comment, user: UserInfo) {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
        nameLabel.text = "\(user.firstName) \(user.lastName)"
    }
    
    
//    var selectionView: UIView?
    
    func customSelect(selected: Bool) {
        setHighlighted(selected, animated: true)
//        selectionView = UIView()
//        if let v = selectionView {
//            if selected {
//                v.backgroundColor = UIColor.lightGrayColor()
//                v.alpha = 0
//                self.contentView.addSubview(v)
//                v.alignToView(self.contentView)
//                UIView.animateWithDuration(0.3, animations: {
//                    v.alpha = 1
//                })
//            } else {
//                UIView.animateWithDuration(0.3, animations: {
//                    v.alpha = 1
//                    }, completion: {
//                        b in
//                        v.removeFromSuperview()
//                })
//            }
//        }
    }
    
    
    func initWebView() {
        textContainerView.addSubview(commentWebView)
        commentWebView.alignToView(textContainerView)
        webViewHelper = CellWebViewHelper(webView: commentWebView, heightWithoutWebView: 17)
        commentWebView.hidden = true
    }
    
    let tapG = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clearColor()
        
        tapG.numberOfTapsRequired = 1
        tapG.addTarget(self, action: #selector(DiscussionTableViewCell.didTap(_:)))
        self.contentView.addGestureRecognizer(tapG)
        
        initLabel()
        initWebView()
    }
    
    func didTap(g: UITapGestureRecognizer) {
        setHighlighted(true, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentWebView.hidden = true
        commentLabel.hidden = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension DiscussionTableViewCell : TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(text: String) -> (Void -> Int) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            commentWebView.hidden = false
            return webViewHelper.setTextWithTeX(text)
        } else {
            commentLabel.hidden = false
            commentLabel.setTextWithHTMLString(text)
            let w = textContainerView.bounds.width 
            return {
                return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 16))) + 17
                
            }
        }
    }
}