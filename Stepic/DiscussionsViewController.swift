//
//  DiscussionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage

@available(*, deprecated, message: "Legacy assembly")
final class DiscussionsLegacyAssembly: Assembly {
    private let discussionProxyId: String
    private let stepId: Step.IdType

    init(discussionProxyId: String, stepId: Step.IdType) {
        self.discussionProxyId = discussionProxyId
        self.stepId = stepId
    }

    func makeModule() -> UIViewController {
        let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil)
        vc.discussionProxyId = self.discussionProxyId
        vc.target = self.stepId
        vc.presenter = DiscussionsPresenter()
        return vc
    }
}

enum SeparatorType {
    case small
    case big
    case none
}

struct DiscussionsCellInfo {
    var comment: Comment?
    var loadRepliesFor: Comment?
    var loadDiscussions: Bool?
    var separatorType: SeparatorType = .none

    init(comment: Comment, separatorType: SeparatorType) {
        self.comment = comment
        self.separatorType = separatorType
    }

    init(loadRepliesFor: Comment) {
        self.loadRepliesFor = loadRepliesFor
    }

    init(loadDiscussions: Bool) {
        self.loadDiscussions = loadDiscussions
    }
}

final class DiscussionsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private enum EmptyDatasetState {
        case error
        case empty
        case none
    }

    private struct DiscussionIds {
        var all = [Int]()
        var loaded = [Int]()

        var leftToLoad: Int {
            return self.all.count - self.loaded.count
        }
    }

    private struct Replies {
        var loaded = [Int: [Comment]]()

        func leftToLoad(_ comment: Comment) -> Int {
            if let loadedCount = self.loaded[comment.id]?.count {
                return comment.repliesIds.count - loadedCount
            } else {
                return comment.repliesIds.count
            }
        }
    }

    var discussionProxyId: String!
    var target: Int!

    var presenter: DiscussionsPresenterProtocol?

    var placeholderContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: StepikTableView!
    private var refreshControl: UIRefreshControl? = UIRefreshControl()

    private var isReloading = false

    private var cellsInfo = [DiscussionsCellInfo]()

    private var discussionIds = DiscussionIds()
    private var replies = Replies()
    private var discussions = [Comment]()
    private var votes = [String: Vote]()

    private let discussionLoadingInterval = 20
    private let repliesLoadingInterval = 20

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

        self.registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.reloadDiscussions()
        }), for: .connectionError)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyDiscussions)
        self.tableView.loadingPlaceholder = StepikPlaceholder(.emptyDiscussionsLoading)

        self.emptyDatasetState = .none

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0

        self.tableView.tableFooterView = UIView()

        self.tableView.register(cellClass: DiscussionTableViewCell.self)
        self.tableView.register(cellClass: LoadMoreTableViewCell.self)

        self.title = NSLocalizedString("Discussions", comment: "")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(DiscussionsViewController.writeCommentBarButtonItemPressed)
        )

        self.refreshControl?.addTarget(
            self,
            action: #selector(DiscussionsViewController.reloadDiscussions),
            for: .valueChanged
        )
        self.tableView.addSubview(self.refreshControl ?? UIView())
        self.refreshControl?.beginRefreshing()

        self.reloadDiscussions()

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Discussions.opened.send()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    private func resetData(reload: Bool) {
        self.discussionIds = DiscussionIds()
        self.replies = Replies()
        self.discussions = [Comment]()

        if reload {
            self.reloadTableData()
        }
    }

    private func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = self.discussionIds.loaded.count
        let offset = min(self.discussionLoadingInterval, self.discussionIds.leftToLoad)
        return Array(self.discussionIds.all[startIndex..<startIndex + offset])
    }

    private func getNextReplyIdsToLoad(discussion: Comment) -> [Int] {
        let loadedReplies = Set(replies.loaded[discussion.id]?.map { $0.id } ?? [])
        var idsToLoad = [Int]()

        for replyId in discussion.repliesIds {
            if !loadedReplies.contains(replyId) {
                idsToLoad.append(replyId)
                if idsToLoad.count == self.repliesLoadingInterval {
                    return idsToLoad
                }
            }
        }

        return idsToLoad
    }

    private func loadDiscussions(ids: [Int], success: (() -> Void)? = nil) {
        self.emptyDatasetState = .none

        // TODO: Check if token should be refreshed before that request
        performRequest({
            _ = ApiDataDownloader.comments.retrieve(ids, success: { [weak self] retrievedDiscussions in
                guard let strongSelf = self else {
                    return
                }

                // Get superDiscussions (those who have no parents)
                let superDiscussions = retrievedDiscussions
                    .filter({ $0.parentId == nil })
                    .reordered(order: ids, transform: { $0.id })

                strongSelf.discussionIds.loaded += ids
                strongSelf.discussions += superDiscussions
                strongSelf.discussions.sort { $0.time.compare($1.time) == .orderedDescending }

                var changedDiscussionIds = Set<Int>()
                // Get all replies
                retrievedDiscussions
                    .filter { $0.parentId != nil }
                    .forEach { reply in
                        if let parentId = reply.parentId {
                            strongSelf.replies.loaded[parentId, default: []] += [reply]
                            changedDiscussionIds.insert(parentId)
                        }
                    }

                for discussionId in changedDiscussionIds {
                    if let discussionIndex = strongSelf.discussions.firstIndex(where: { $0.id == discussionId }) {
                        strongSelf.replies.loaded[discussionId] = strongSelf.replies.loaded[discussionId, default: []]
                            .reordered(order: strongSelf.discussions[discussionIndex].repliesIds, transform: { $0.id })
                            .sorted { $0.time.compare($1.time) == .orderedAscending }
                    }
                }

                success?()
            }, error: { [weak self] errorString in
                print("DiscussionsViewController :: \(errorString)")
                self?.emptyDatasetState = .error
                DispatchQueue.main.async {
                    self?.refreshControl?.endRefreshing()
                }
            })
        }, error: { [weak self] error in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }

                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.reloadDiscussions()
                    }, cancel: nil)
                }
            }
        })
    }

    private func reloadTableData(_ emptyState: EmptyDatasetState = .empty) {
        self.cellsInfo = []

        for discussion in self.discussions {
            self.cellsInfo.append(DiscussionsCellInfo(comment: discussion, separatorType: .small))

            for reply in self.replies.loaded[discussion.id] ?? [] {
                self.cellsInfo.append(DiscussionsCellInfo(comment: reply, separatorType: .small))
            }

            let leftToLoad = self.replies.leftToLoad(discussion)
            if leftToLoad > 0 {
                cellsInfo.append(DiscussionsCellInfo(loadRepliesFor: discussion))
            } else {
                cellsInfo[cellsInfo.count - 1].separatorType = .big
            }
        }

        if self.discussionIds.leftToLoad > 0 {
            self.cellsInfo.append(DiscussionsCellInfo(loadDiscussions: true))
        }

        DispatchQueue.main.async {
            if self.cellsInfo.count == 0 {
                self.emptyDatasetState = emptyState
            }
            self.tableView.reloadData()
        }
    }

    @objc
    private func reloadDiscussions() {
        func onLoaded(success: Bool) {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.isReloading = false
                strongSelf.refreshControl?.endRefreshing()
                strongSelf.reloadTableData(success ? .empty : .error)
            }
        }

        self.emptyDatasetState = .none

        if self.isReloading {
            return
        }

        self.resetData(reload: false)
        self.isReloading = true

        performRequest({ [weak self] in
            guard let discussionProxyId = self?.discussionProxyId else {
                return
            }

            _ = ApiDataDownloader.discussionProxies.retrieve(discussionProxyId, success: { [weak self] discussionProxy in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.discussionIds.all = discussionProxy.discussionIds
                strongSelf.loadDiscussions(
                    ids: strongSelf.getNextDiscussionIdsToLoad(),
                    success: { onLoaded(success: true) }
                )
            }, error: { errorString in
                print("DiscussionsViewController :: \(errorString)")
                onLoaded(success: false)
            })
        }, error: { [weak self] error in
            print("DiscussionsViewController :: \(error)")
            guard let strongSelf = self else {
                return
            }

            onLoaded(success: false)

            if error == PerformRequestError.noAccessToRefreshToken {
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                    self?.reloadDiscussions()
                }, cancel: nil)
            }
        })
    }

    private func setLiked(comment: Comment, cell: UITableViewCell) {
        guard let cell = cell as? DiscussionTableViewCell else {
            return
        }

        if let voteValue = comment.vote.value {
            // Unlike comment.
            let voteValueToSet: VoteValue? = voteValue == .epic ? nil : .epic
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            performRequest({
                _ = ApiDataDownloader.votes.update(vote, success: { vote in
                    comment.vote = vote
                    switch voteValue {
                    case .abuse:
                        comment.abuseCount -= 1
                        comment.epicCount += 1
                        cell.setLiked(true, likesCount: comment.epicCount)
                        AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked, parameters: nil)
                    case .epic:
                        comment.epicCount -= 1
                        cell.setLiked(false, likesCount: comment.epicCount)
                        AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.unliked, parameters: nil)
                    }
                }, error: { errorString in
                    print("DiscussionsViewController :: \(errorString)")
                })
            }, error: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.reloadDiscussions()
                    }, cancel: nil)
                }
            })
        } else {
            // Like comment.
            let vote = Vote(id: comment.vote.id, value: .epic)
            performRequest({
                _ = ApiDataDownloader.votes.update(vote, success: { vote in
                    comment.vote = vote
                    comment.epicCount += 1
                    cell.setLiked(true, likesCount: comment.epicCount)
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked, parameters: nil)
                }, error: { errorString in
                    print("DiscussionsViewController :: \(errorString)")
                })
            }, error: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.reloadDiscussions()
                    }, cancel: nil)
                }
            })
        }
    }

    private func setAbused(_ comment: Comment, cell: UITableViewCell) {
        guard let cell = cell as? DiscussionTableViewCell else {
            return
        }

        if let voteValue = comment.vote.value {
            let vote = Vote(id: comment.vote.id, value: .abuse)
            performRequest({
                _ = ApiDataDownloader.votes.update(vote, success: { vote in
                    comment.vote = vote
                    switch voteValue {
                    case .abuse:
                        break
                    case .epic:
                        comment.epicCount -= 1
                        comment.abuseCount += 1
                        cell.setLiked(false, likesCount: comment.epicCount)
                        AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused, parameters: nil)
                    }
                }, error: { errorString in
                    print("DiscussionsViewController :: \(errorString)")
                })
            }, error: { [weak self] error in
                print("DiscussionsViewController :: \(error)")
                guard let strongSelf = self else {
                    return
                }

                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.reloadDiscussions()
                    }, cancel: nil)
                }
            })
        } else {
            let vote = Vote(id: comment.vote.id, value: .abuse)
            performRequest({
                _ = ApiDataDownloader.votes.update(vote, success: { vote in
                    comment.vote = vote
                    comment.abuseCount += 1
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused, parameters: nil)
                }, error: { errorString in
                    print("DiscussionsViewController :: \(errorString)")
                })
            }, error: { [weak self] error in
                print("DiscussionsViewController :: \(error)")
                guard let strongSelf = self else {
                    return
                }

                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.reloadDiscussions()
                    }, cancel: nil)
                }
            })
        }
    }

    private func handleSelectDiscussion(_ comment: Comment, cell: UITableViewCell, completion: (() -> Void)?) {
        let alert = DiscussionAlertConstructor.getCommentAlert(
            comment: comment,
            replyBlock: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                if !AuthInfo.shared.isAuthorized {
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.presentWriteComment(parent: comment.parentId ?? comment.id)
                    }, cancel: nil)
                } else {
                    self?.presentWriteComment(parent: comment.parentId ?? comment.id)
                }
            },
            likeBlock: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                if !AuthInfo.shared.isAuthorized {
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.setLiked(comment: comment, cell: cell)
                    }, cancel: nil)
                } else {
                    self?.setLiked(comment: comment, cell: cell)
                }
            },
            abuseBlock: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                if !AuthInfo.shared.isAuthorized {
                    RoutingManager.auth.routeFrom(controller: strongSelf, success: { [weak self] in
                        self?.setAbused(comment, cell: cell)
                    }, cancel: nil)
                } else {
                    self?.setAbused(comment, cell: cell)
                }
            },
            openURLBlock: { [weak self] url in
                guard let strongSelf = self else {
                    return
                }

                WebControllerManager.sharedManager.presentWebControllerWithURL(
                    url,
                    inController: strongSelf,
                    withKey: "external link",
                    allowsSafari: true,
                    backButtonStyle: BackButtonStyle.close
                )
            }
        )

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }

        self.present(alert, animated: true, completion: { completion?() })
    }

    // MARK: Actions

    @objc
    private func writeCommentBarButtonItemPressed() {
        if !AuthInfo.shared.isAuthorized {
            RoutingManager.auth.routeFrom(controller: self, success: { [weak self] in
                self?.presentWriteComment(parent: nil)
            }, cancel: nil)
        } else {
            self.presentWriteComment(parent: nil)
        }
    }

    private func presentWriteComment(parent: Int?) {
        let assembly = WriteCommentLegacyAssembly(target: self.target, parentId: parent, delegate: self)
        self.navigationController?.pushViewController(assembly.makeModule(), animated: true)
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
        // Select discussion.
        if let comment = self.cellsInfo[(indexPath as NSIndexPath).row].comment {
            if let cell = tableView.cellForRow(at: indexPath) {
                self.handleSelectDiscussion(comment, cell: cell, completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.deselectRow(at: indexPath, animated: true)
                    }
                })
            }
        }

        // Load more replies.
        if let loadRepliesFor = self.cellsInfo[indexPath.row].loadRepliesFor {
            let idsToLoad = self.getNextReplyIdsToLoad(discussion: loadRepliesFor)
            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell {
                cell.isUpdating = true
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.loadDiscussions(ids: idsToLoad, success: { [weak self, weak cell] in
                    DispatchQueue.main.async {
                        self?.reloadTableData()
                        cell?.isUpdating = false
                    }
                })
            }
        }

        // Load more comments.
        if self.cellsInfo[indexPath.row].loadDiscussions != nil {
            let idsToLoad = self.getNextDiscussionIdsToLoad()
            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell {
                cell.isUpdating = true
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.loadDiscussions(ids: idsToLoad, success: { [weak self, weak cell] in
                    DispatchQueue.main.async {
                        self?.reloadTableData()
                        cell?.isUpdating = false
                    }
                })
            }
        }
    }
}

extension DiscussionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comment = self.cellsInfo[indexPath.row].comment {
            let cell: DiscussionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.initWithComment(comment, separatorType: self.cellsInfo[indexPath.row].separatorType)
            cell.delegate = self
            return cell
        }

        if let loadRepliesFor = self.cellsInfo[indexPath.row].loadRepliesFor {
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.showMoreLabel.text = "\(NSLocalizedString("ShowMoreReplies", comment: "")) (\(self.replies.leftToLoad(loadRepliesFor)))"
            return cell
        }

        if self.cellsInfo[indexPath.row].loadDiscussions != nil {
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.showMoreLabel.text = "\(NSLocalizedString("ShowMoreDiscussions", comment: "")) (\(self.discussionIds.leftToLoad))"
            return cell
        }

        return UITableViewCell()
    }
}

extension DiscussionsViewController: WriteCommentViewControllerDelegate {
    func writeCommentViewControllerDidWriteComment(_ controller: WriteCommentViewController, comment: Comment) {
        if let parentId = comment.parentId {
            // Insert row in an existing section.
            if let section = self.discussions.index(where: { $0.id == parentId }) {
                self.discussions[section].repliesIds += [comment.id]
                if replies.loaded[parentId] == nil {
                    self.replies.loaded[parentId] = []
                }
                self.replies.loaded[parentId]! += [comment]
                self.reloadTableData()
            }
        } else {
            // Insert section.
            self.discussionIds.all.insert(comment.id, at: 0)
            self.discussionIds.loaded.insert(comment.id, at: 0)
            self.discussions.insert(comment, at: 0)
            self.reloadTableData()
            
            // TODO: increment discussions count
            //self.step?.discussionsCount? += 1
        }
    }
}

extension DiscussionsViewController: DiscussionTableViewCellDelegate {
    func discussionTableViewCellDidRequestOpenProfile(_ cell: DiscussionTableViewCell, forUserWithId userID: Int) {
        // TODO: Add Assembly and remove DeepLinks from here. It is not a correct DeepLink use case.
        DeepLinkRouter.routeToProfileWithId(userID) { [weak self] viewControllers in
            if var stack = self?.navigationController?.viewControllers {
                stack.append(contentsOf: viewControllers)
                self?.navigationController?.setViewControllers(stack, animated: true)
            }
        }
    }
}
