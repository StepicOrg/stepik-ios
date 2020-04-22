import Foundation

struct DiscussionsDiscussionViewModel {
    let comment: DiscussionsCommentViewModel
    let replies: [DiscussionsCommentViewModel]

    let repliesLeftToLoadCount: Int
    let formattedRepliesLeftToLoad: String
    let isFetchingMoreReplies: Bool

    var id: Int { self.comment.id }
}

struct DiscussionsCommentViewModel {
    let id: Int
    let avatarImageURL: URL?
    let userID: User.IdType
    let userRoleBadgeText: String?
    let isPinned: Bool
    let isSelected: Bool
    let username: String
    let strippedText: String
    let processedText: String
    let isWebViewSupportNeeded: Bool
    let formattedDate: String
    let likesCount: Int
    let dislikesCount: Int
    let voteValue: VoteValue?
    let canEdit: Bool
    let canDelete: Bool
    let canVote: Bool
    let hasReplies: Bool
    let solution: Solution?

    struct Solution {
        let id: Submission.IdType
        let title: String
        let isCorrect: Bool
    }
}
