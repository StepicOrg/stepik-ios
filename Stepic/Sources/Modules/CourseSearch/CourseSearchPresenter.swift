import UIKit

protocol CourseSearchPresenterProtocol {
    func presentCourseSearchLoadResult(response: CourseSearch.CourseSearchLoad.Response)
    func presentCourseSearchSuggestionsLoadResult(response: CourseSearch.CourseSearchSuggestionsLoad.Response)
    func presentSearchQueryUpdateResult(response: CourseSearch.SearchQueryUpdate.Response)
    func presentSearchResults(response: CourseSearch.Search.Response)
    func presentNextSearchResults(response: CourseSearch.NextSearchResultsLoad.Response)
    func presentCommentUser(response: CourseSearch.CommentUserPresentation.Response)
    func presentCommentDiscussion(response: CourseSearch.CommentDiscussionPresentation.Response)
    func presentLesson(response: CourseSearch.LessonPresentation.Response)
    func presentLoadingState(response: CourseSearch.LoadingStatePresentation.Response)
}

final class CourseSearchPresenter: CourseSearchPresenterProtocol {
    weak var viewController: CourseSearchViewControllerProtocol?

    func presentCourseSearchLoadResult(response: CourseSearch.CourseSearchLoad.Response) {
        switch response.result {
        case .success(let data):
            let placeholderText = String(
                format: NSLocalizedString("CourseSearchBarPlaceholder", comment: ""),
                arguments: [data.course?.title ?? ""]
            ).trimmed()

            let suggestions = data.suggestions.map(self.makeSuggestionViewModel(_:))

            self.viewController?.displayCourseSearchLoadResult(
                viewModel: .init(placeholderText: placeholderText, suggestions: suggestions)
            )
        case .failure:
            break
        }
    }

    func presentCourseSearchSuggestionsLoadResult(response: CourseSearch.CourseSearchSuggestionsLoad.Response) {
        let suggestions = response.suggestions.map(self.makeSuggestionViewModel(_:))
        self.viewController?.displayCourseSearchSuggestionsLoadResult(viewModel: .init(suggestions: suggestions))
    }

    func presentSearchQueryUpdateResult(response: CourseSearch.SearchQueryUpdate.Response) {
        let suggestions = response.suggestions.map(self.makeSuggestionViewModel(_:))
        self.viewController?.displaySearchQueryUpdateResult(
            viewModel: .init(query: response.query, suggestions: suggestions)
        )
    }

    func presentSearchResults(response: CourseSearch.Search.Response) {
        switch response.result {
        case .success(let data):
            let resultData = CourseSearch.SearchResultData(
                searchResults: data.searchResults.map(self.makeSearchResultViewModel(_:)),
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displaySearchResults(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displaySearchResults(viewModel: .init(state: .error))
        }
    }

    func presentNextSearchResults(response: CourseSearch.NextSearchResultsLoad.Response) {
        switch response.result {
        case .success(let data):
            let resultData = CourseSearch.SearchResultData(
                searchResults: data.searchResults.map(self.makeSearchResultViewModel(_:)),
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayNextSearchResults(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displayNextSearchResults(viewModel: .init(state: .error))
        }
    }

    func presentCommentUser(response: CourseSearch.CommentUserPresentation.Response) {
        self.viewController?.displayCommentUser(viewModel: .init(userID: response.userID))
    }

    func presentCommentDiscussion(response: CourseSearch.CommentDiscussionPresentation.Response) {
        guard let discussionProxyID = response.searchResult.stepDiscussionProxyID,
              let stepID = response.searchResult.stepID else {
            return
        }

        let isTeacher = response.searchResult.lessonCanEdit ?? false

        let presentationContext: Discussions.PresentationContext = {
            if let commentID = response.searchResult.commentID {
                if let commentParentID = response.searchResult.commentParentID {
                    return .scrollTo(discussionID: commentParentID, replyID: commentID)
                } else {
                    return .scrollTo(discussionID: commentID, replyID: nil)
                }
            } else {
                return .fromBeginning
            }
        }()

        self.viewController?.displayCommentDiscussion(
            viewModel: .init(
                discussionProxyID: discussionProxyID,
                stepID: stepID,
                isTeacher: isTeacher,
                presentationContext: presentationContext
            )
        )
    }

    func presentLesson(response: CourseSearch.LessonPresentation.Response) {
        self.viewController?.displayLesson(viewModel: .init(lessonID: response.lessonID, stepID: response.stepID))
    }

    func presentLoadingState(response: CourseSearch.LoadingStatePresentation.Response) {
        self.viewController?.displayLoadingState(viewModel: .init())
    }

    // MARK: Private API

    private func makeSuggestionViewModel(_ searchQueryResult: SearchQueryResult) -> CourseSearchSuggestionViewModel {
        .init(uniqueIdentifier: searchQueryResult.id, title: searchQueryResult.query)
    }

    private func makeSearchResultViewModel(_ searchResult: SearchResultPlainObject) -> CourseSearchResultViewModel {
        let title: String = {
            var resultTitle = ""

            let lessonTitle = searchResult.lessonTitle ?? ""
            let stepPositionTitle = String(
                format: NSLocalizedString("StepPosition", comment: ""),
                arguments: ["\(searchResult.stepPosition ?? 0)"]
            )

            if let sectionPosition = searchResult.sectionPosition,
               let unitPosition = searchResult.unitPosition {
                resultTitle = "\(sectionPosition).\(unitPosition) \(lessonTitle)".trimmed()
            } else {
                resultTitle = "\(lessonTitle)"
            }

            if searchResult.isStep || searchResult.isComment {
                resultTitle = "\(resultTitle) - \(stepPositionTitle)"
            }

            return resultTitle
        }()

        let coverImageURL: URL? = {
            if let lessonCoverURL = searchResult.lessonCoverURL {
                return URL(string: lessonCoverURL)
            }
            return nil
        }()

        let likesCount: Int? = {
            if let lessonVoteDelta = searchResult.lessonVoteDelta {
                return lessonVoteDelta == 0 ? nil : lessonVoteDelta
            }
            return nil
        }()

        let learnersLabelText: String? = {
            if let lessonPassedBy = searchResult.lessonPassedBy {
                return FormatterHelper.longNumber(lessonPassedBy)
            }
            return nil
        }()

        let progressLabelText: String? = {
            guard let progress = searchResult.unitProgress,
                  progress.cost > 0 else {
                return nil
            }

            return String(
                format: NSLocalizedString("CourseInfoTabSyllabusUnitProgressTitle", comment: ""),
                arguments: ["\(FormatterHelper.progressScore(progress.score))", "\(progress.cost)"]
            )
        }()

        let timeToCompleteLabelText: String? = {
            guard let timeToComplete = searchResult.lessonTimeToComplete else {
                return nil
            }

            if timeToComplete < 60 {
                return nil
            } else if case 60..<3600 = timeToComplete {
                return FormatterHelper.minutesInSeconds(timeToComplete, roundingRule: .down)
            } else {
                return FormatterHelper.hoursInSeconds(timeToComplete, roundingRule: .down)
            }
        }()

        let commentViewModel: CourseSearchResultViewModel.Comment? = {
            guard searchResult.isComment else {
                return nil
            }

            let avatarImageURL: URL?
            let username: String

            if let commentUserInfo = searchResult.commentUserInfo {
                avatarImageURL = URL(string: commentUserInfo.avatarURL)
                username = FormatterHelper.username(commentUserInfo)
            } else {
                avatarImageURL = nil
                username = "User \(searchResult.commentUserID ??? "n/a")"
            }

            return CourseSearchResultViewModel.Comment(
                avatarImageURL: avatarImageURL,
                username: username,
                text: searchResult.commentText ?? ""
            )
        }()

        return CourseSearchResultViewModel(
            uniqueIdentifier: "\(searchResult.id)",
            title: title,
            coverImageURL: coverImageURL,
            likesCount: likesCount,
            learnersLabelText: learnersLabelText,
            progressLabelText: progressLabelText,
            timeToCompleteLabelText: timeToCompleteLabelText,
            comment: commentViewModel
        )
    }
}
