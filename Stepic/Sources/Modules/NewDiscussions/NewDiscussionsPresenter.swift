import UIKit

protocol NewDiscussionsPresenterProtocol {
    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response)
    func presentNextDiscussions(response: NewDiscussions.NextDiscussionsLoad.Response)
    func presentNextReplies(response: NewDiscussions.NextRepliesLoad.Response)
    func presentWriteComment(response: NewDiscussions.WriteCommentPresentation.Response)
    func presentCommentCreated(response: NewDiscussions.CommentCreated.Response)
    func presentWaitingState(response: WriteCourseReview.BlockingWaitingIndicatorUpdate.Response)
}

final class NewDiscussionsPresenter: NewDiscussionsPresenterProtocol {
    weak var viewController: NewDiscussionsViewControllerProtocol?

    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response) {
        var viewModel: NewDiscussions.DiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(
                discussionProxy: result.discussionProxy,
                discussions: result.discussions,
                discussionsIDsFetchingMore: result.discussionsIDsFetchingMore,
                replies: result.replies,
                sortType: result.sortType
            )
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
            let data = self.makeDiscussionsData(
                discussionProxy: result.discussionProxy,
                discussions: result.discussions,
                discussionsIDsFetchingMore: result.discussionsIDsFetchingMore,
                replies: result.replies,
                sortType: result.sortType
            )
            viewModel = NewDiscussions.NextDiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = NewDiscussions.NextDiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayNextDiscussions(viewModel: viewModel)
    }

    func presentNextReplies(response: NewDiscussions.NextRepliesLoad.Response) {
        let data = self.makeDiscussionsData(
            discussionProxy: response.result.discussionProxy,
            discussions: response.result.discussions,
            discussionsIDsFetchingMore: response.result.discussionsIDsFetchingMore,
            replies: response.result.replies,
            sortType: response.result.sortType
        )

        self.viewController?.displayNextReplies(viewModel: NewDiscussions.NextRepliesLoad.ViewModel(data: data))
    }

    func presentWriteComment(response: NewDiscussions.WriteCommentPresentation.Response) {
        self.viewController?.displayWriteComment(
            viewModel: NewDiscussions.WriteCommentPresentation.ViewModel(stepID: response.stepID)
        )
    }

    func presentCommentCreated(response: NewDiscussions.CommentCreated.Response) {
        let data = self.makeDiscussionsData(
            discussionProxy: response.result.discussionProxy,
            discussions: response.result.discussions,
            discussionsIDsFetchingMore: response.result.discussionsIDsFetchingMore,
            replies: response.result.replies,
            sortType: response.result.sortType
        )

        self.viewController?.displayCommentCreated(
            viewModel: NewDiscussions.CommentCreated.ViewModel(data: data)
        )
    }

    func presentWaitingState(response: WriteCourseReview.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(
            viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel(shouldDismiss: response.shouldDismiss)
        )
    }

    // MARK: - Private API -

    private func makeDiscussionsData(
        discussionProxy: DiscussionProxy,
        discussions: [Comment],
        discussionsIDsFetchingMore: Set<Comment.IdType>,
        replies: [Comment.IdType: [Comment]],
        sortType: NewDiscussions.SortType
    ) -> NewDiscussions.DiscussionsResult {
        assert(discussions.filter({ !$0.repliesIDs.isEmpty }).count == replies.keys.count)

        let discussions = self.sortedDiscussions(
            discussions,
            discussionProxy: discussionProxy,
            by: sortType
        )

        let discussionsViewModels = discussions.map { discussion in
            self.makeDiscussionViewModel(
                discussion: discussion,
                replies: replies[discussion.id] ?? [],
                isFetchingMoreReplies: discussionsIDsFetchingMore.contains(discussion.id)
            )
        }

        let discussionsLeftToLoad = self.getDiscussionsIDs(
            discussionProxy: discussionProxy,
            sortType: sortType
        ).count - discussions.count

        return NewDiscussions.DiscussionsResult(
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

        let dateRepresentation = comment.time.getStepicFormatString(withTime: true)

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
            voteValue: voteValue
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
