import UIKit

protocol DiscussionsPresenterProtocol {
    func presentDiscussions(response: Discussions.DiscussionsLoad.Response)
    func presentNextDiscussions(response: Discussions.NextDiscussionsLoad.Response)
    func presentNextReplies(response: Discussions.NextRepliesLoad.Response)
    func presentWriteComment(response: Discussions.WriteCommentPresentation.Response)
    func presentCommentCreate(response: Discussions.CommentCreated.Response)
    func presentCommentUpdate(response: Discussions.CommentUpdated.Response)
    func presentCommentDelete(response: Discussions.CommentDelete.Response)
    func presentCommentLike(response: Discussions.CommentLike.Response)
    func presentCommentAbuse(response: Discussions.CommentAbuse.Response)
    func presentSortTypes(response: Discussions.SortTypesPresentation.Response)
    func presentSortTypeUpdate(response: Discussions.SortTypeUpdate.Response)
    func presentWaitingState(response: Discussions.BlockingWaitingIndicatorUpdate.Response)
}

final class DiscussionsPresenter: DiscussionsPresenterProtocol {
    weak var viewController: DiscussionsViewControllerProtocol?

    func presentDiscussions(response: Discussions.DiscussionsLoad.Response) {
        var viewModel: Discussions.DiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = Discussions.DiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = Discussions.DiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayDiscussions(viewModel: viewModel)
    }

    func presentNextDiscussions(response: Discussions.NextDiscussionsLoad.Response) {
        var viewModel: Discussions.NextDiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = Discussions.NextDiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = Discussions.NextDiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayNextDiscussions(viewModel: viewModel)
    }

    func presentNextReplies(response: Discussions.NextRepliesLoad.Response) {
        self.viewController?.displayNextReplies(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentWriteComment(response: Discussions.WriteCommentPresentation.Response) {
        let presentationContext: WriteComment.PresentationContext = {
            switch response.presentationContext {
            case .create:
                return .create
            case .edit:
                return .edit(response.comment.require())
            }
        }()

        self.viewController?.displayWriteComment(
            viewModel: .init(
                targetID: response.targetID,
                parentID: response.parentID,
                presentationContext: presentationContext
            )
        )
    }

    func presentCommentCreate(response: Discussions.CommentCreated.Response) {
        self.viewController?.displayCommentCreate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentUpdate(response: Discussions.CommentUpdated.Response) {
        self.viewController?.displayCommentUpdate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentDelete(response: Discussions.CommentDelete.Response) {
        switch response.result {
        case .success(let data):
            self.viewController?.displayCommentDelete(
                viewModel: .init(state: .result(data: self.makeDiscussionsData(data)))
            )
        case .failure:
            self.viewController?.displayCommentDelete(viewModel: .init(state: .error))
        }
    }

    func presentCommentLike(response: Discussions.CommentLike.Response) {
        self.viewController?.displayCommentLike(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentAbuse(response: Discussions.CommentAbuse.Response) {
        let data = self.makeDiscussionsData(response.result)
        self.viewController?.displayCommentAbuse(viewModel: .init(data: data))
    }

    func presentSortTypes(response: Discussions.SortTypesPresentation.Response) {
        let items = response.availableSortTypes.map { sortType -> Discussions.SortTypesPresentation.ViewModel.Item in
            var title: String = {
                switch sortType {
                case .last:
                    return NSLocalizedString("DiscussionsSortTypeLastDiscussions", comment: "")
                case .mostLiked:
                    return NSLocalizedString("DiscussionsSortTypeMostLikedDiscussions", comment: "")
                case .mostActive:
                    return NSLocalizedString("DiscussionsSortTypeMostActiveDiscussions", comment: "")
                case .recentActivity:
                    return NSLocalizedString("DiscussionsSortTypeRecentActivityDiscussions", comment: "")
                }
            }()

            if sortType == response.currentSortType {
                title = "\(title) ✔︎"
            }

            return .init(uniqueIdentifier: sortType.rawValue, title: title)
        }

        self.viewController?.displaySortTypesAlert(
            viewModel: .init(title: NSLocalizedString("DiscussionsSortTypeAlertTitle", comment: ""), items: items)
        )
    }

    func presentSortTypeUpdate(response: Discussions.SortTypeUpdate.Response) {
        self.viewController?.displaySortTypeUpdate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentWaitingState(response: Discussions.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    // MARK: - Private API -

    private func makeDiscussionsData(
        _ data: Discussions.DiscussionsResponseData
    ) -> Discussions.DiscussionsViewData {
        assert(data.discussions.filter({ !$0.repliesIDs.isEmpty }).count == data.replies.keys.count)

        let discussions = self.sortedDiscussions(
            data.discussions,
            discussionProxy: data.discussionProxy,
            by: data.currentSortType
        )

        let discussionsViewModels = discussions.map { discussion in
            self.makeDiscussionViewModel(
                discussion: discussion,
                replies: data.replies[discussion.id] ?? [],
                isFetchingMoreReplies: data.discussionsIDsFetchingMore.contains(discussion.id)
            )
        }

        let discussionsLeftToLoadCount = self.getDiscussionsIDs(
            discussionProxy: data.discussionProxy,
            sortType: data.currentSortType
        ).count - discussions.count

        return .init(discussions: discussionsViewModels, discussionsLeftToLoad: discussionsLeftToLoadCount)
    }

    private func makeCommentViewModel(comment: Comment) -> DiscussionsCommentViewModel {
        let avatarImageURL: URL? = {
            if let userInfo = comment.userInfo {
                return URL(string: userInfo.avatarURL)
            }
            return nil
        }()

        let username: String = {
            let userIDString = "User \(comment.userID)"
            if let userInfo = comment.userInfo {
                let fullName = "\(userInfo.firstName) \(userInfo.lastName)"
                return fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? userIDString : fullName
            }
            return userIDString
        }()

        let isWebViewSupportNeeded = TagDetectionUtil.isWebViewSupportNeeded(comment.text)

        let text: String = {
            let trimmedText = comment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if isWebViewSupportNeeded {
                let contentProcessor = ContentProcessor(
                    content: trimmedText,
                    rules: ContentProcessor.defaultRules,
                    injections: ContentProcessor.defaultInjections
                )
                return contentProcessor.processContent()
            }
            return trimmedText
        }()

        let formattedDate = FormatterHelper.dateToRelativeString(comment.time)

        let voteValue: VoteValue? = {
            if let vote = comment.vote {
                return vote.value
            }
            return nil
        }()

        return DiscussionsCommentViewModel(
            id: comment.id,
            avatarImageURL: avatarImageURL,
            userID: comment.userID,
            userRole: comment.userRole,
            isPinned: comment.isPinned,
            username: username,
            text: text,
            isWebViewSupportNeeded: isWebViewSupportNeeded,
            formattedDate: formattedDate,
            likesCount: comment.epicCount,
            dislikesCount: comment.abuseCount,
            voteValue: voteValue,
            canEdit: comment.actions.contains(.edit),
            canDelete: comment.actions.contains(.delete),
            canVote: comment.actions.contains(.vote)
        )
    }

    private func makeDiscussionViewModel(
        discussion: Comment,
        replies: [Comment],
        isFetchingMoreReplies: Bool
    ) -> DiscussionsDiscussionViewModel {
        let repliesViewModels = self.sortedReplies(
            replies,
            parentDiscussion: discussion
        ).map { self.makeCommentViewModel(comment: $0) }

        let leftToLoadCount = discussion.repliesIDs.count - repliesViewModels.count

        return DiscussionsDiscussionViewModel(
            comment: self.makeCommentViewModel(comment: discussion),
            replies: repliesViewModels,
            repliesLeftToLoadCount: leftToLoadCount,
            formattedRepliesLeftToLoad: "\(NSLocalizedString("ShowMoreDiscussions", comment: "")) (\(leftToLoadCount))",
            isFetchingMoreReplies: isFetchingMoreReplies
        )
    }

    private func sortedDiscussions(
        _ discussions: [Comment],
        discussionProxy: DiscussionProxy,
        by sortType: Discussions.SortType
    ) -> [Comment] {
        return discussions.reordered(
            order: self.getDiscussionsIDs(discussionProxy: discussionProxy, sortType: sortType),
            transform: { $0.id }
        )
    }

    private func sortedReplies(_ replies: [Comment], parentDiscussion discussion: Comment) -> [Comment] {
        return replies
            .reordered(order: discussion.repliesIDs, transform: { $0.id })
            .sorted { $0.time.compare($1.time) == .orderedAscending }
    }

    private func getDiscussionsIDs(
        discussionProxy: DiscussionProxy,
        sortType: Discussions.SortType
    ) -> [Comment.IdType] {
        switch sortType {
        case .last:
            return discussionProxy.discussionsIDs
        case .mostLiked:
            return discussionProxy.discussionsIDsMostLiked
        case .mostActive:
            return discussionProxy.discussionsIDsMostActive
        case .recentActivity:
            return discussionProxy.discussionsIDsRecentActivity
        }
    }
}
