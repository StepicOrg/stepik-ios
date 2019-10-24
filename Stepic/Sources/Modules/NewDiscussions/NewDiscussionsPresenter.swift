import UIKit

protocol NewDiscussionsPresenterProtocol {
    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response)
    func presentNextDiscussions(response: NewDiscussions.NextDiscussionsLoad.Response)
    func presentNextReplies(response: NewDiscussions.NextRepliesLoad.Response)
    func presentWriteComment(response: NewDiscussions.WriteCommentPresentation.Response)
    func presentCommentCreated(response: NewDiscussions.CommentCreated.Response)
    func presentCommentUpdated(response: NewDiscussions.CommentUpdated.Response)
    func presentCommentDeleteResult(response: NewDiscussions.CommentDelete.Response)
    func presentSortType(response: NewDiscussions.SortTypePresentation.Response)
    func presentSortTypeUpdate(response: NewDiscussions.SortTypeUpdate.Response)
    func presentWaitingState(response: NewDiscussions.BlockingWaitingIndicatorUpdate.Response)
}

final class NewDiscussionsPresenter: NewDiscussionsPresenterProtocol {
    weak var viewController: NewDiscussionsViewControllerProtocol?

    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response) {
        var viewModel: NewDiscussions.DiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = NewDiscussions.DiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = NewDiscussions.DiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayDiscussions(viewModel: viewModel)
    }

    func presentNextDiscussions(response: NewDiscussions.NextDiscussionsLoad.Response) {
        var viewModel: NewDiscussions.NextDiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = NewDiscussions.NextDiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = NewDiscussions.NextDiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayNextDiscussions(viewModel: viewModel)
    }

    func presentNextReplies(response: NewDiscussions.NextRepliesLoad.Response) {
        let data = self.makeDiscussionsData(response.result)
        self.viewController?.displayNextReplies(viewModel: NewDiscussions.NextRepliesLoad.ViewModel(data: data))
    }

    func presentWriteComment(response: NewDiscussions.WriteCommentPresentation.Response) {
        let presentationContext: WriteComment.PresentationContext = {
            switch response.presentationContext {
            case .create:
                return .create
            case .edit:
                return .edit(response.comment.require())
            }
        }()

        self.viewController?.displayWriteComment(
            viewModel: NewDiscussions.WriteCommentPresentation.ViewModel(
                targetID: response.targetID,
                parentID: response.parentID,
                presentationContext: presentationContext
            )
        )
    }

    func presentCommentCreated(response: NewDiscussions.CommentCreated.Response) {
        let data = self.makeDiscussionsData(response.result)
        self.viewController?.displayCommentCreated(viewModel: NewDiscussions.CommentCreated.ViewModel(data: data))
    }

    func presentCommentUpdated(response: NewDiscussions.CommentUpdated.Response) {
        let data = self.makeDiscussionsData(response.result)
        self.viewController?.displayCommentUpdated(viewModel: NewDiscussions.CommentUpdated.ViewModel(data: data))
    }

    func presentCommentDeleteResult(response: NewDiscussions.CommentDelete.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeDiscussionsData(data)
            self.viewController?.displayCommentDeleteResult(
                viewModel: NewDiscussions.CommentDelete.ViewModel(state: .result(data: viewModel))
            )
        case .failure:
            self.viewController?.displayCommentDeleteResult(
                viewModel: NewDiscussions.CommentDelete.ViewModel(state: .error)
            )
        }
    }

    func presentSortType(response: NewDiscussions.SortTypePresentation.Response) {
        let items = response.availableSortTypes.map { sortType -> NewDiscussions.SortTypePresentation.ViewModel.Item in
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

        self.viewController?.displaySortTypeAlert(
            viewModel: NewDiscussions.SortTypePresentation.ViewModel(
                title: NSLocalizedString("DiscussionsSortTypeAlertTitle", comment: ""),
                items: items
            )
        )
    }

    func presentSortTypeUpdate(response: NewDiscussions.SortTypeUpdate.Response) {
        self.viewController?.displaySortTypeUpdate(
            viewModel: NewDiscussions.SortTypeUpdate.ViewModel(data: self.makeDiscussionsData(response.result))
        )
    }

    func presentWaitingState(response: NewDiscussions.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(
            viewModel: NewDiscussions.BlockingWaitingIndicatorUpdate.ViewModel(shouldDismiss: response.shouldDismiss)
        )
    }

    // MARK: - Private API -

    private func makeDiscussionsData(
        _ data: NewDiscussions.DiscussionsResponseData
    ) -> NewDiscussions.DiscussionsViewData {
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

        let discussionsLeftToLoad = self.getDiscussionsIDs(
            discussionProxy: data.discussionProxy,
            sortType: data.currentSortType
        ).count - discussions.count

        return NewDiscussions.DiscussionsViewData(
            discussions: discussionsViewModels,
            discussionsLeftToLoad: discussionsLeftToLoad
        )
    }

    private func makeCommentViewModel(comment: Comment) -> NewDiscussionsCommentViewModel {
        let avatarImageURL: URL? = {
            if let userInfo = comment.userInfo {
                return URL(string: userInfo.avatarURL)
            }
            return nil
        }()

        let userName: String = {
            if let userInfo = comment.userInfo {
                return "\(userInfo.firstName) \(userInfo.lastName)"
            }
            return "Unknown"
        }()

        let dateRepresentation = FormatterHelper.dateToRelativeString(comment.time)

        let voteValue: VoteValue? = {
            if let vote = comment.vote {
                return vote.value
            }
            return nil
        }()

        return NewDiscussionsCommentViewModel(
            id: comment.id,
            avatarImageURL: avatarImageURL,
            userRole: comment.userRole,
            isPinned: comment.isPinned,
            userName: userName,
            text: comment.text,
            dateRepresentation: dateRepresentation,
            likesCount: comment.epicCount,
            dislikesCount: comment.abuseCount,
            voteValue: voteValue,
            canEdit: comment.actions.contains(.edit),
            canDelete: comment.actions.contains(.delete)
        )
    }

    private func makeDiscussionViewModel(
        discussion: Comment,
        replies: [Comment],
        isFetchingMoreReplies: Bool
    ) -> NewDiscussionsDiscussionViewModel {
        let repliesViewModels = self.sortedReplies(
            replies,
            parentDiscussion: discussion
        ).map { self.makeCommentViewModel(comment: $0) }

        let leftToLoad = discussion.repliesIDs.count - repliesViewModels.count

        return NewDiscussionsDiscussionViewModel(
            comment: self.makeCommentViewModel(comment: discussion),
            replies: repliesViewModels,
            repliesLeftToLoad: leftToLoad,
            formattedRepliesLeftToLoad: "\(NSLocalizedString("ShowMoreDiscussions", comment: "")) (\(leftToLoad))",
            isFetchingMoreReplies: isFetchingMoreReplies
        )
    }

    private func sortedDiscussions(
        _ discussions: [Comment],
        discussionProxy: DiscussionProxy,
        by sortType: NewDiscussions.SortType
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
        sortType: NewDiscussions.SortType
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
