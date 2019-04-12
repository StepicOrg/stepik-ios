//
//  DiscussionWebTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage
import WebKit
import SnapKit

class DiscussionWebTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: AvatarImageView!
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
    var heightUpdateBlock: ((CGFloat, CGFloat) -> Void)?
    var commentWebView: WKWebView?

    fileprivate func constructWebView() {
        let theConfiguration = WKWebViewConfiguration()
        let contentController = theConfiguration.userContentController
        contentController.addUserScript( WKUserScript(
            source: "window.onload=function () { window.webkit.messageHandlers.sizeNotification.postMessage({width: document.width, height: document.height});};",
            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
            forMainFrameOnly: false
            ))

        contentController.add(self, name: "sizeNotification")

        commentWebView = WKWebView(frame: CGRect.zero, configuration: theConfiguration)

        commentWebView?.scrollView.isScrollEnabled = false
        commentWebView?.backgroundColor = UIColor.clear
        commentWebView?.scrollView.backgroundColor = UIColor.clear
        self.webContainerView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.commentWebView?.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        commentWebView?.translatesAutoresizingMaskIntoConstraints = true
        contentView.translatesAutoresizingMaskIntoConstraints = true

        webContainerView.addSubview(commentWebView!)
        commentWebView?.snp.makeConstraints { $0.edges.equalTo(webContainerView) }
    }

    func initWithComment(_ comment: Comment, separatorType: SeparatorType) {
        if let url = URL(string: comment.userInfo.avatarURL) {
            userAvatarImageView.set(with: url)
        }

        nameLabel.text = "\(comment.userInfo.firstName) \(comment.userInfo.lastName)"
        self.comment = comment
        self.separatorType = separatorType

        timeLabel.text = comment.time.getStepicFormatString()
        loadWebView(comment.text)
    }

    fileprivate func loadWebView(_ htmlString: String) {
        let processor = HTMLProcessor(html: htmlString)
        let html = processor
            .injectDefault()
            .html

        commentWebView?.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    fileprivate func setLeadingConstraints(_ constant: CGFloat) {
        ImageLeadingConstraint.constant = constant
        webViewLeadingConstraint.constant = constant
        switch self.separatorType {
        case .small:
            separatorLeadingConstraint.constant = -constant + 8
            break
        default:
            break
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 999999.0, height: 999999.0)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension DiscussionWebTableViewCell : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let height = (message.body as? NSDictionary)?["height"] as? CGFloat {
            DispatchQueue.main.async(execute: {
                [weak self] in
                self?.webContainerViewHeight?.constant = height
                self?.heightUpdateBlock?(height + (self?.separatorHeightConstraint.constant ?? 0) + 69, height)
                self?.layoutSubviews()
            })
        }
    }
}
