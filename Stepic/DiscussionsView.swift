import Foundation

enum SeparatorType {
    case small
    case big
    case none
}

struct DiscussionsViewData {
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

protocol DiscussionsView: class {
    func setViewData(_ viewData: [DiscussionsViewData])
    func displayError(_ error: Error)
    func displayWriteComment(parentId: Comment.IdType?)
    func displayDiscussionAlert(comment: Comment)
}
