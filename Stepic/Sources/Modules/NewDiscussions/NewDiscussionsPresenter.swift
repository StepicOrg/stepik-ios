import UIKit

protocol NewDiscussionsPresenterProtocol {
    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response)
}

final class NewDiscussionsPresenter: NewDiscussionsPresenterProtocol {
    weak var viewController: NewDiscussionsViewControllerProtocol?

    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response) {
        var viewModel: NewDiscussions.DiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            assert(result.discussions.filter({ !$0.repliesIDs.isEmpty }).count == result.replies.keys.count)

            let discussions = self.sortedDiscussions(
                result.discussions,
                discussionProxy: result.discussionProxy,
                by: result.sortType
            )

            let discussionsViewModels = discussions.map { discussion in
                self.makeDiscussionViewModel(discussion: discussion, replies: result.replies[discussion.id])
            }

            let discussionsLeftToLoad = self.getDiscussionsIDs(
                discussionProxy: result.discussionProxy,
                sortType: result.sortType
            ).count - discussions.count

            viewModel = NewDiscussions.DiscussionsLoad.ViewModel(
                state: .result(
                    data: NewDiscussions.DiscussionsResult(
                        discussions: discussionsViewModels,
                        discussionsLeftToLoad: discussionsLeftToLoad
                    )
                )
            )
        case .failure:
            viewModel = NewDiscussions.DiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayDiscussions(viewModel: viewModel)
    }

    // MARK: - Private API

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

    // swiftlint:disable:next discouraged_optional_collection
    private func makeDiscussionViewModel(
        discussion: Comment,
        replies: [Comment]?
    ) -> NewDiscussionsDiscussionViewModel {
        let repliesViewModels = self.sortedReplies(
            replies ?? [],
            parentDiscussion: discussion
        ).map { self.makeCommentViewModel(comment: $0) }

        return NewDiscussionsDiscussionViewModel(
            comment: self.makeCommentViewModel(comment: discussion),
            replies: repliesViewModels,
            repliesLeftToLoad: discussion.repliesIDs.count - repliesViewModels.count
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
