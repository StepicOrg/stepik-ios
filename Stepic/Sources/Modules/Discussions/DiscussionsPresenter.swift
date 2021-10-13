import Kanna
import UIKit

protocol DiscussionsPresenterProtocol {
    func presentNavigationItemUpdate(response: Discussions.NavigationItemUpdate.Response)
    func presentDiscussions(response: Discussions.DiscussionsLoad.Response)
    func presentNextDiscussions(response: Discussions.NextDiscussionsLoad.Response)
    func presentNextReplies(response: Discussions.NextRepliesLoad.Response)
    func presentSelectComment(response: Discussions.SelectComment.Response)
    func presentWriteComment(response: Discussions.WriteCommentPresentation.Response)
    func presentCommentCreate(response: Discussions.CommentCreated.Response)
    func presentCommentUpdate(response: Discussions.CommentUpdated.Response)
    func presentCommentDelete(response: Discussions.CommentDelete.Response)
    func presentCommentLike(response: Discussions.CommentLike.Response)
    func presentCommentAbuse(response: Discussions.CommentAbuse.Response)
    func presentSortTypes(response: Discussions.SortTypesPresentation.Response)
    func presentSortTypeUpdate(response: Discussions.SortTypeUpdate.Response)
    func presentSolution(response: Discussions.SolutionPresentation.Response)
    func presentCommentActionSheet(response: Discussions.CommentActionSheetPresentation.Response)
    func presentWaitingState(response: Discussions.BlockingWaitingIndicatorUpdate.Response)
    func presentCommentNotFoundStatus(response: Discussions.CommentNotFoundPresentation.Response)
}

final class DiscussionsPresenter: DiscussionsPresenterProtocol {
    weak var viewController: DiscussionsViewControllerProtocol?

    func presentNavigationItemUpdate(response: Discussions.NavigationItemUpdate.Response) {
        switch response.threadType {
        case .default:
            self.viewController?.displayNavigationItemUpdate(
                viewModel: .init(
                    title: NSLocalizedString("DiscussionsTitle", comment: ""),
                    shouldShowSortButton: true,
                    shouldShowComposeButton: true,
                    threadType: .default
                )
            )
        case .solutions:
            self.viewController?.displayNavigationItemUpdate(
                viewModel: .init(
                    title: NSLocalizedString("DiscussionThreadSolutionsTitle", comment: ""),
                    shouldShowSortButton: true,
                    shouldShowComposeButton: true,
                    threadType: .solutions
                )
            )
        }
    }

    func presentDiscussions(response: Discussions.DiscussionsLoad.Response) {
        var viewModel: Discussions.DiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = Discussions.DiscussionsLoad.ViewModel(state: .result(data: data))
        case .failure:
            viewModel = Discussions.DiscussionsLoad.ViewModel(state: .error)
        }

        self.viewController?.displayDiscussions(viewModel: viewModel)
    }

    func presentNextDiscussions(response: Discussions.NextDiscussionsLoad.Response) {
        var viewModel: Discussions.NextDiscussionsLoad.ViewModel

        switch response.result {
        case .success(let result):
            let data = self.makeDiscussionsData(result)
            viewModel = .init(state: .result(data: data), direction: response.direction)
        case .failure:
            viewModel = .init(state: .error, direction: response.direction)
        }

        self.viewController?.displayNextDiscussions(viewModel: viewModel)
    }

    func presentNextReplies(response: Discussions.NextRepliesLoad.Response) {
        self.viewController?.displayNextReplies(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentSelectComment(response: Discussions.SelectComment.Response) {
        self.viewController?.displaySelectComment(viewModel: .init(commentID: response.commentID))
    }

    func presentWriteComment(response: Discussions.WriteCommentPresentation.Response) {
        self.viewController?.displayWriteComment(
            viewModel: .init(
                targetID: response.targetID,
                parentID: response.parentID,
                comment: response.comment,
                discussionThreadType: response.discussionThreadType
            )
        )
    }

    func presentCommentCreate(response: Discussions.CommentCreated.Response) {
        self.viewController?.displayCommentCreate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentUpdate(response: Discussions.CommentUpdated.Response) {
        self.viewController?.displayCommentUpdate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentDelete(response: Discussions.CommentDelete.Response) {
        switch response.result {
        case .success(let data):
            self.viewController?.displayCommentDelete(
                viewModel: .init(state: .result(data: self.makeDiscussionsData(data)))
            )
        case .failure:
            self.viewController?.displayCommentDelete(viewModel: .init(state: .error))
        }
    }

    func presentCommentLike(response: Discussions.CommentLike.Response) {
        self.viewController?.displayCommentLike(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentCommentAbuse(response: Discussions.CommentAbuse.Response) {
        let data = self.makeDiscussionsData(response.result)
        self.viewController?.displayCommentAbuse(viewModel: .init(data: data))
    }

    func presentSortTypes(response: Discussions.SortTypesPresentation.Response) {
        let items = response.availableSortTypes.map { sortType -> Discussions.SortTypesPresentation.ViewModel.Item in
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

        self.viewController?.displaySortTypesAlert(
            viewModel: .init(title: NSLocalizedString("DiscussionsSortTypeAlertTitle", comment: ""), items: items)
        )
    }

    func presentSortTypeUpdate(response: Discussions.SortTypeUpdate.Response) {
        self.viewController?.displaySortTypeUpdate(viewModel: .init(data: self.makeDiscussionsData(response.result)))
    }

    func presentSolution(response: Discussions.SolutionPresentation.Response) {
        self.viewController?.displaySolution(
            viewModel: .init(
                stepID: response.stepID,
                submission: response.submission,
                discussionID: response.discussionID
            )
        )
    }

    func presentCommentActionSheet(response: Discussions.CommentActionSheetPresentation.Response) {
        let commentViewModel = self.makeCommentViewModel(
            comment: response.comment,
            selectedCommentID: nil,
            hasReplies: false
        )

        self.viewController?.displayCommentActionSheet(
            viewModel: .init(
                stepID: response.stepID,
                isTeacher: response.isTeacher,
                isTheoryStep: response.isTheoryStep,
                comment: commentViewModel
            )
        )
    }

    func presentWaitingState(response: Discussions.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentCommentNotFoundStatus(response: Discussions.CommentNotFoundPresentation.Response) {
        let status = String(
            format: NSLocalizedString("DiscussionsCommentNotFoundTitle", comment: ""),
            arguments: ["\(response.commentID)"]
        )
        self.viewController?.displayCommentNotFoundStatus(viewModel: .init(status: status))
    }

    // MARK: - Private API -

    private func makeDiscussionsData(
        _ data: Discussions.ResponseData
    ) -> Discussions.ViewData {
        let discussions = self.sortedDiscussions(
            data.discussions,
            discussionProxy: data.discussionProxy,
            by: data.currentSortType
        )

        let discussionsViewModels = discussions.map { discussion in
            self.makeDiscussionViewModel(
                discussion: discussion,
                replies: data.replies[discussion.id] ?? [],
                isFetchingMoreReplies: data.discussionsIDsFetchingMore.contains(discussion.id),
                selectedCommentID: data.selectedCommentID
            )
        }

        return .init(
            discussions: discussionsViewModels,
            hasPreviousPage: data.discussionsLeftToLoadInLeftHalf > 0,
            hasNextPage: data.discussionsLeftToLoadInRightHalf > 0
        )
    }

    private func makeCommentViewModel(
        comment: Comment,
        selectedCommentID: Comment.IdType?,
        hasReplies: Bool
    ) -> DiscussionsCommentViewModel {
        let avatarImageURL: URL? = {
            if let userInfo = comment.userInfo {
                return URL(string: userInfo.avatarURL)
            }
            return nil
        }()

        let userRoleBadgeText: String? = {
            switch comment.userRole {
            case .student:
                return nil
            case .teacher, .assistant:
                return NSLocalizedString("CourseStaff", comment: "")
            case .staff:
                return NSLocalizedString("Staff", comment: "")
            case .moderator:
                return NSLocalizedString("CourseModerator", comment: "")
            }
        }()

        let username = comment.userInfo != nil
            ? FormatterHelper.username(comment.userInfo.require())
            : "User \(comment.userID)"

        let processedContent: ProcessedContent = {
            let appearance = DiscussionsCellView.Appearance()

            let contentProcessor = ContentProcessor(
                rules: ContentProcessor.defaultRules,
                injections: ContentProcessor.defaultInjections + [
                    FontInjection(font: appearance.processedContentViewLabelFont),
                    TextColorInjection(dynamicColor: appearance.secondaryTextColor)
                ]
            )

            let processedContent = contentProcessor.processContent(comment.text)

            return processedContent
        }()

        let formattedDate = FormatterHelper.dateToRelativeString(comment.time)

        let voteValue: VoteValue? = {
            if let vote = comment.vote {
                return vote.value
            }
            return nil
        }()

        let strippedText: String = {
            do {
                if comment.text.trimmed().isEmpty {
                    return comment.text
                }

                let htmlDocument = try Kanna.HTML(html: comment.text, encoding: .utf8)

                return htmlDocument.css("*").first?.text ?? comment.text
            } catch {
                return comment.text
            }
        }()
        let strippedAndTrimmedText = strippedText.trimmingCharacters(in: .whitespacesAndNewlines)

        let solution: DiscussionsCommentViewModel.Solution? = {
            guard let submission = comment.submission else {
                return nil
            }

            return .init(
                id: submission.id,
                title: String(
                    format: NSLocalizedString("DiscussionThreadCommentSolutionTitle", comment: ""),
                    arguments: ["\(submission.id)"]
                ),
                status: QuizStatus(submission: submission) ?? .wrong
            )
        }()

        return DiscussionsCommentViewModel(
            id: comment.id,
            avatarImageURL: avatarImageURL,
            userID: comment.userID,
            userRoleBadgeText: userRoleBadgeText,
            isPinned: comment.isPinned,
            isSelected: comment.id == selectedCommentID,
            username: username,
            strippedText: strippedAndTrimmedText,
            processedContent: processedContent,
            formattedDate: formattedDate,
            likesCount: max(0, comment.epicCount),
            dislikesCount: max(0, comment.abuseCount),
            voteValue: voteValue,
            canEdit: comment.actions.contains(.edit),
            canDelete: comment.actions.contains(.delete),
            canVote: comment.actions.contains(.vote),
            hasReplies: hasReplies,
            solution: solution
        )
    }

    private func makeDiscussionViewModel(
        discussion: Comment,
        replies: [Comment],
        isFetchingMoreReplies: Bool,
        selectedCommentID: Comment.IdType?
    ) -> DiscussionsDiscussionViewModel {
        let repliesViewModels = self.sortedReplies(
            replies,
            parentDiscussion: discussion
        ).map { self.makeCommentViewModel(comment: $0, selectedCommentID: selectedCommentID, hasReplies: false) }

        let hasReplies = !discussion.repliesIDs.isEmpty
        let leftToLoadCount = discussion.repliesIDs.count - repliesViewModels.count

        return DiscussionsDiscussionViewModel(
            comment: self.makeCommentViewModel(
                comment: discussion,
                selectedCommentID: selectedCommentID,
                hasReplies: hasReplies
            ),
            replies: repliesViewModels,
            repliesLeftToLoadCount: leftToLoadCount,
            formattedRepliesLeftToLoad: "\(NSLocalizedString("ShowMoreDiscussions", comment: "")) (\(leftToLoadCount))",
            isFetchingMoreReplies: isFetchingMoreReplies
        )
    }

    private func sortedDiscussions(
        _ discussions: [Comment],
        discussionProxy: DiscussionProxy,
        by sortType: Discussions.SortType
    ) -> [Comment] {
        discussions.reordered(
            order: self.getDiscussionsIDs(discussionProxy: discussionProxy, sortType: sortType),
            transform: { $0.id }
        )
    }

    private func sortedReplies(_ replies: [Comment], parentDiscussion discussion: Comment) -> [Comment] {
        replies
            .reordered(order: discussion.repliesIDs, transform: { $0.id })
            .sorted { $0.time.compare($1.time) == .orderedAscending }
    }

    private func getDiscussionsIDs(
        discussionProxy: DiscussionProxy,
        sortType: Discussions.SortType
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
