import Foundation

struct NewDiscussionsDiscussionViewModel {
    let comment: NewDiscussionsCommentViewModel
    let replies: [NewDiscussionsCommentViewModel]

    let repliesLeftToLoad: Int
    let formattedRepliesLeftToLoad: String
    let isFetchingMoreReplies: Bool

    var id: Int {
        return self.comment.id
    }
}

struct NewDiscussionsCommentViewModel {
    let id: Int
    let avatarImageURL: URL?
    let userRole: UserRole
    let isPinned: Bool
    let userName: String
    let text: String
    let dateRepresentation: String
    let likesCount: Int
    let dislikesCount: Int
    let voteValue: VoteValue?
    let canEdit: Bool
    let canDelete: Bool
}
