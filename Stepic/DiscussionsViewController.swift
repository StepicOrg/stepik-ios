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
            votesNetworkService: VotesNetworkService(votesAPI: VotesAPI())
        )
        vc.title = NSLocalizedString("Discussions", comment: "")
        return vc
    }
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

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshDiscussions), for: .valueChanged)
        return refreshControl
    }()

    private var viewData = [DiscussionsViewData]()

    private var discussions = [Comment]()
    private var votes = [String: Vote]()

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

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyDiscussions)
        self.tableView.loadingPlaceholder = StepikPlaceholder(.emptyDiscussionsLoading)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.tableView.register(cellClass: DiscussionTableViewCell.self)
        self.tableView.register(cellClass: LoadMoreTableViewCell.self)
        self.tableView.addSubview(self.refreshControl)

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
        self.viewData = viewData

        if self.viewData.count == 0 {
            self.emptyDatasetState = .empty
        }

        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    func displayError(_ error: Error) {
        self.emptyDatasetState = .error
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

extension DiscussionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter?.selectViewData(self.viewData[indexPath.row])
    }
}

extension DiscussionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewData = self.viewData[indexPath.row]
        if let comment = viewData.comment {
            let cell: DiscussionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(comment: comment, separatorType: viewData.separatorType)
            cell.delegate = self
            return cell
        } else if viewData.loadRepliesFor != nil || viewData.loadDiscussions {
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.showMoreLabel.text = viewData.showMoreText
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension DiscussionsViewController: WriteCommentViewControllerDelegate {
    func writeCommentViewControllerDidWriteComment(_ controller: WriteCommentViewController, comment: Comment) {
        self.presenter?.writeComment(comment)
    }
}

extension DiscussionsViewController: DiscussionTableViewCellDelegate {
    func discussionTableViewCellDidRequestOpenProfile(_ cell: DiscussionTableViewCell, forUserWithId userID: Int) {
        let assembly = ProfileAssembly(userID: userID)
        self.push(module: assembly.makeModule())
    }
}
