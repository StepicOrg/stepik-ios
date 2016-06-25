//
//  DiscussionWebTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import SDWebImage
import WebKit

class DiscussionWebTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var ImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var webContainerViewHeight: NSLayoutConstraint!
    
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
    var heightUpdateBlock : ((CGFloat, CGFloat)->Void)?
    var commentWebView: WKWebView?
    
    private func constructWebView() {
        let theConfiguration = WKWebViewConfiguration()
        let contentController = theConfiguration.userContentController
        contentController.addUserScript( WKUserScript(
            source: "window.onload=function () { window.webkit.messageHandlers.sizeNotification.postMessage({width: document.width, height: document.height});};",
            injectionTime: WKUserScriptInjectionTime.AtDocumentStart,
            forMainFrameOnly: false
            ))
        
        contentController.addScriptMessageHandler(self, name: "sizeNotification")
        
        commentWebView = WKWebView(frame: CGRectZero, configuration: theConfiguration)
        
        commentWebView?.scrollView.scrollEnabled = false
        commentWebView?.backgroundColor = UIColor.clearColor()
        commentWebView?.scrollView.backgroundColor = UIColor.clearColor()
        self.webContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.commentWebView?.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        commentWebView?.translatesAutoresizingMaskIntoConstraints = true
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        webContainerView.addSubview(commentWebView!)
        commentWebView?.alignToView(webContainerView)
    }
    
    func initWithComment(comment: Comment, user: UserInfo, separatorType: SeparatorType)  {
        userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        self.comment = comment
        self.separatorType = separatorType
        
        timeLabel.text = comment.lastTime.getStepicFormatString()
        loadWebView(comment.text)
    }
    
    private func loadWebView(htmlString: String) {
        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
        commentWebView?.loadHTMLString(wrapped, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
    }
    
    private func setLeadingConstraints(constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        webViewLeadingConstraint.constant = constant
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
        self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 999999.0, height: 999999.0)
        userAvatarImageView.setRoundedBounds(width: 0)
        constructWebView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comment = nil
        webContainerViewHeight.constant = 23
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

extension DiscussionWebTableViewCell : WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let height = message.body["height"] as? CGFloat {
            dispatch_async(dispatch_get_main_queue(), {
                [weak self] in
                self?.webContainerViewHeight?.constant = height
                self?.heightUpdateBlock?(height + (self?.separatorHeightConstraint.constant ?? 0) + 69, height)
                self?.layoutSubviews()
            })
        }
    }

}