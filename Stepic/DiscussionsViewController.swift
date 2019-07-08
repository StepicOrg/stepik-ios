//
//  DiscussionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

@available(*, deprecated, message: "Legacy assembly")
final class DiscussionsLegacyAssembly: Assembly {
    private let discussionProxyID: String
    private let stepID: Step.IdType

    init(discussionProxyID: String, stepID: Step.IdType) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
    }

    func makeModule() -> UIViewController {
        let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil)
        vc.discussionProxyId = self.discussionProxyID
        vc.target = self.stepID
        vc.presenter = DiscussionsPresenter(
            view: vc,
            discussionProxyId: self.discussionProxyID,
            stepId: self.stepID,
            discussionProxiesNetworkService: DiscussionProxiesNetworkService(
                discussionProxiesAPI: DiscussionProxiesAPI()
            ),
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI()),
            votesNetworkService: VotesNetworkService(votesAPI: VotesAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        vc.title = NSLocalizedString("Discussions", comment: "")
        return vc
    }
}

protocol DiscussionsViewControllerDelegate: class {
    func cellDidSelect(_ viewData: DiscussionsViewData)
    func profileButtonDidClick(_ userId: Int)
}

final class DiscussionsViewController: UIViewController, DiscussionsView, ControllerWithStepikPlaceholder {
    private enum EmptyDatasetState {
        case error
        case empty
        case none
    }

    var discussionProxyId: String!
    var target: Int!
    var presenter: DiscussionsPresenterProtocol?

    @IBOutlet weak var tableView: StepikTableView!
    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let tableDataSource = DiscussionsTableViewDataSource()
    private let refreshControl = UIRefreshControl()

    private var emptyDatasetState: EmptyDatasetState = .none {
        didSet {
            switch self.emptyDatasetState {
            case .none:
                self.isPlaceholderShown = false
                self.tableView.showLoadingPlaceholder()
            case .empty:
                self.isPlaceholderShown = false
                self.tableView.reloadData()
            case .error:
                self.showPlaceholder(for: .connectionError)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(self.writeCommentBarButtonItemPressed)
        )

        self.registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.refreshDiscussions()
        }), for: .connectionError)

        self.tableDataSource.delegate = self
        self.tableView.delegate = self.tableDataSource
        self.tableView.dataSource = self.tableDataSource
        self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyDiscussions)
        self.tableView.loadingPlaceholder = StepikPlaceholder(.emptyDiscussionsLoading)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.tableView.register(cellClass: DiscussionTableViewCell.self)
        self.tableView.register(cellClass: LoadMoreTableViewCell.self)
        self.tableView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refreshDiscussions), for: .valueChanged)

        // TODO: Add bottom insets for iPhone X.
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }

        self.emptyDatasetState = .none
        self.refreshDiscussions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Discussions.opened.send()
    }

    @objc
    private func refreshDiscussions() {
        self.refreshControl.beginRefreshing()
        self.presenter?.refresh()
    }

    func setViewData(_ viewData: [DiscussionsViewData]) {
        self.tableDataSource.viewDatas = viewData

        if viewData.count == 0 {
            self.emptyDatasetState = .empty
        }

        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    func displayError(_ error: Error) {
        self.emptyDatasetState = .error
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }

    func displayDiscussionAlert(comment: Comment) {
        let alert = DiscussionAlertConstructor.getCommentAlert(
            comment: comment,
            replyBlock: { [weak self] in
                self?.displayWriteComment(parentId: comment.parentId ?? comment.id)
            },
            likeBlock: { [weak self] in
                self?.presenter?.likeComment(comment)
            },
            abuseBlock: { [weak self] in
                self?.presenter?.abuseComment(comment)
            },
            openURLBlock: { [weak self] url in
                if let strongSelf = self {
                    WebControllerManager.sharedManager.presentWebControllerWithURL(
                        url,
                        inController: strongSelf,
                        withKey: "external link",
                        allowsSafari: true,
                        backButtonStyle: .close
                    )
                }
            }
        )

        // TODO: Fix
        if let popoverController = alert.popoverPresentationController,
           let cell = self.tableView.visibleCells
               .compactMap({ $0 as? DiscussionTableViewCell })
               .first(where: { $0.comment?.id == comment.id }) {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }

        self.present(module: alert)
    }

    func displayWriteComment(parentId: Comment.IdType?) {
        let assembly = WriteCommentLegacyAssembly(target: self.target, parentId: parentId, delegate: self)
        self.push(module: assembly.makeModule())
    }

    @objc
    private func writeCommentBarButtonItemPressed() {
        if !AuthInfo.shared.isAuthorized {
            RoutingManager.auth.routeFrom(controller: self, success: { [weak self] in
                self?.displayWriteComment(parentId: nil)
            }, cancel: nil)
        } else {
            self.displayWriteComment(parentId: nil)
        }
    }
}

extension DiscussionsViewController: DiscussionsViewControllerDelegate {
    func cellDidSelect(_ viewData: DiscussionsViewData) {
        self.presenter?.selectViewData(viewData)
    }
    
    func profileButtonDidClick(_ userId: Int) {
        let assembly = ProfileAssembly(userID: userId)
        self.push(module: assembly.makeModule())
    }
}

extension DiscussionsViewController: WriteCommentViewControllerDelegate {
    func writeCommentViewControllerDidWriteComment(_ controller: WriteCommentViewController, comment: Comment) {
        self.presenter?.writeComment(comment)
    }
}
