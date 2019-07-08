import Foundation

enum SeparatorType {
    case small
    case big
    case none
}

struct DiscussionsViewData {
    let comment: Comment?
    let fetchRepliesFor: Comment?
    let needFetchDiscussions: Bool
    let showMoreText: String
    let isUpdating: Bool
    var separatorType: SeparatorType

    init(comment: Comment, separatorType: SeparatorType) {
        self.comment = comment
        self.fetchRepliesFor = nil
        self.needFetchDiscussions = false
        self.showMoreText = ""
        self.isUpdating = false
        self.separatorType = separatorType
    }

    init(fetchRepliesFor: Comment, showMoreText: String, isUpdating: Bool) {
        self.comment = nil
        self.fetchRepliesFor = fetchRepliesFor
        self.needFetchDiscussions = false
        self.showMoreText = showMoreText
        self.isUpdating = isUpdating
        self.separatorType = .none
    }

    init(needFetchDiscussions: Bool, showMoreText: String, isUpdating: Bool) {
        self.comment = nil
        self.fetchRepliesFor = nil
        self.needFetchDiscussions = needFetchDiscussions
        self.showMoreText = showMoreText
        self.isUpdating = isUpdating
        self.separatorType = .none
    }
}

protocol DiscussionsView: class {
    func setViewData(_ viewData: [DiscussionsViewData])
    func displayError(_ error: Error)
    func displayWriteComment(parentId: Comment.IdType?)
    func displayDiscussionAlert(comment: Comment)
}
