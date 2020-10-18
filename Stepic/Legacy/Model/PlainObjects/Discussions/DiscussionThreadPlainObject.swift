import Foundation

struct DiscussionThreadPlainObject: Equatable {
    let id: String
    let thread: String
    let discussionsCount: Int
    let discussionProxy: String
}

extension DiscussionThreadPlainObject {
    init(discussionThread: DiscussionThread) {
        self.id = discussionThread.id
        self.thread = discussionThread.thread
        self.discussionsCount = discussionThread.discussionsCount
        self.discussionProxy = discussionThread.discussionProxy
    }
}
