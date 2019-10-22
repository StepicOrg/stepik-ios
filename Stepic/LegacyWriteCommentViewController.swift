//
//  WriteCommentViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

@available(*, deprecated, message: "Legacy assembly")
final class WriteCommentLegacyAssembly: Assembly {
    private let target: Step.IdType
    private let parentId: Comment.IdType?

    private weak var delegate: LegacyWriteCommentViewControllerDelegate?

    init(target: Int, parentId: Comment.IdType?, delegate: LegacyWriteCommentViewControllerDelegate? = nil) {
        self.target = target
        self.parentId = parentId
        self.delegate = delegate
    }

    func makeModule() -> UIViewController {
        guard let vc = ControllerHelper.instantiateViewController(
            identifier: "LegacyWriteCommentViewController",
            storyboardName: "DiscussionsStoryboard"
        ) as? LegacyWriteCommentViewController else {
            fatalError()
        }

        vc.parentId = self.parentId
        vc.target = self.target
        vc.delegate = self.delegate

        return vc
    }
}

protocol LegacyWriteCommentViewControllerDelegate: class {
    func legacyWriteCommentViewControllerDidWriteComment(
        _ controller: LegacyWriteCommentViewController,
        comment: Comment
    )
}

final class LegacyWriteCommentViewController: UIViewController {
    enum State {
        case editing
        case sending
        case ok
    }

    @IBOutlet weak var commentTextView: IQTextView!

    weak var delegate: LegacyWriteCommentViewControllerDelegate?

    var target: Int!
    var parentId: Int?

    private let commentsAPI = CommentsAPI()

    private lazy var editBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(
            image: Images.sendImage,
            style: .done,
            target: self,
            action: #selector(LegacyWriteCommentViewController.sendPressed)
        )
    }()

    private lazy var sendBarButtonItem: UIBarButtonItem = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.color = .mainDark
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }()

    private lazy var okBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(
            image: Images.checkMarkImage,
            style: .done,
            target: self,
            action: #selector(LegacyWriteCommentViewController.okPressed)
        )
    }()

    private var state: State = .editing {
        didSet {
            switch self.state {
            case .sending:
                self.view.endEditing(true)
                self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
            case .ok:
                self.navigationItem.rightBarButtonItem = self.okBarButtonItem
            case .editing:
                self.commentTextView.becomeFirstResponder()
                self.navigationItem.rightBarButtonItem = self.editBarButtonItem
            }
        }
    }

    private var htmlText: String {
        let text = self.commentTextView.text ?? ""
        return text.replacingOccurrences(of: "\n", with: "<br>")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Comment", comment: "")

        self.commentTextView.placeholder = NSLocalizedString("WriteComment", comment: "")
        self.commentTextView.tintColor = .mainDark
        self.commentTextView.textColor = .mainText

        self.state = .editing
    }

    @objc
    private func okPressed() {
        print("should have never been pressed")
    }

    @objc
    private func sendPressed() {
        self.state = .sending
        let comment = Comment(parent: self.parentId, target: self.target, text: self.htmlText)

        self.commentsAPI.create(comment).done { [weak self] comment in
            guard let strongSelf = self else {
                return
            }

            strongSelf.state = .ok

            strongSelf.delegate?.legacyWriteCommentViewControllerDidWriteComment(strongSelf, comment: comment)
            strongSelf.navigationController?.popViewController(animated: true)
        }.catch { [weak self] _ in
            self?.state = .editing
        }
    }
}
