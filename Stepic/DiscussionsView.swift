import Foundation

enum SeparatorType {
    case small
    case big
    case none
}

struct DiscussionsViewData {
    let comment: Comment?
    let loadRepliesFor: Comment?
    let loadDiscussions: Bool
    var separatorType: SeparatorType

    init(comment: Comment, separatorType: SeparatorType) {
        self.comment = comment
        self.loadRepliesFor = nil
        self.loadDiscussions = false
        self.separatorType = separatorType
    }

    init(loadRepliesFor: Comment) {
        self.comment = nil
        self.loadRepliesFor = loadRepliesFor
        self.loadDiscussions = false
        self.separatorType = .none
    }

    init(loadDiscussions: Bool) {
        self.comment = nil
        self.loadRepliesFor = nil
        self.loadDiscussions = loadDiscussions
        self.separatorType = .none
    }
}

protocol DiscussionsView: class {
    func setViewData(_ viewData: [DiscussionsViewData])
    func displayError(_ error: Error)
    func displayWriteComment(parentId: Comment.IdType?)
    func displayDiscussionAlert(comment: Comment)
}
