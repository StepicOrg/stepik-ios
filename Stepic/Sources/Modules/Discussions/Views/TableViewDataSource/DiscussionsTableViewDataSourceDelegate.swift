import Foundation

protocol DiscussionsTableViewDataSourceDelegate: AnyObject {
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didReplyForComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didLikeComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didDislikeComment comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectAvatar comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectMoreAction comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectSolution comment: DiscussionsCommentViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectLoadMoreRepliesForDiscussion discussion: DiscussionsDiscussionViewModel
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didSelectComment comment: DiscussionsCommentViewModel,
        at indexPath: IndexPath,
        cell: UITableViewCell
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didRequestOpenURL url: URL
    )
    func discussionsTableViewDataSource(
        _ dataSource: DiscussionsTableViewDataSource,
        didRequestOpenImage url: URL
    )
}
