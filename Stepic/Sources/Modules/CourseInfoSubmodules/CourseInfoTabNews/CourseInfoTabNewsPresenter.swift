import PromiseKit
import UIKit

protocol CourseInfoTabNewsPresenterProtocol {
    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response)
    func presentNextCourseNews(response: CourseInfoTabNews.NextNewsLoad.Response)
}

final class CourseInfoTabNewsPresenter: CourseInfoTabNewsPresenterProtocol {
    weak var viewController: CourseInfoTabNewsViewControllerProtocol?

    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response) {
        switch response.result {
        case .success(let data):
            self.makeNewsViewModels(data.announcements, currentUser: data.currentUser).done { viewModels in
                let data = CourseInfoTabNews.NewsResultData(news: viewModels, hasNextPage: data.hasNextPage)
                self.viewController?.displayCourseNews(viewModel: .init(state: .result(data: data)))
            }
        case .failure:
            self.viewController?.displayCourseNews(viewModel: .init(state: .error))
        }
    }

    func presentNextCourseNews(response: CourseInfoTabNews.NextNewsLoad.Response) {
        switch response.result {
        case .success(let data):
            self.makeNewsViewModels(data.announcements, currentUser: data.currentUser).done { viewModels in
                let data = CourseInfoTabNews.NewsResultData(news: viewModels, hasNextPage: data.hasNextPage)
                self.viewController?.displayNextCourseNews(viewModel: .init(state: .result(data: data)))
            }
        case .failure:
            self.viewController?.displayNextCourseNews(viewModel: .init(state: .error))
        }
    }

    // MARK: Private API

    private func makeNewsViewModels(
        _ announcements: [AnnouncementPlainObject],
        currentUser: User?
    ) -> Guarantee<[CourseInfoTabNewsViewModel]> {
        Guarantee { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                let contentProcessor = self.makeContentProcessor(currentUser: currentUser)
                let viewModels = announcements.map { self.makeViewModel($0, contentProcessor: contentProcessor) }

                DispatchQueue.main.async {
                    seal(viewModels)
                }
            }
        }
    }

    private func makeViewModel(
        _ announcement: AnnouncementPlainObject,
        contentProcessor: ContentProcessor
    ) -> CourseInfoTabNewsViewModel {
        let formattedDate = FormatterHelper.dateStringWithFullMonthAndYear(announcement.sentDate ?? Date())

        let processedContent = contentProcessor.processContent(announcement.text)

        return CourseInfoTabNewsViewModel(
            uniqueIdentifier: "\(announcement.id)",
            formattedDate: formattedDate,
            subject: announcement.subject.trimmed(),
            processedContent: processedContent
        )
    }

    private func makeContentProcessor(currentUser: User?) -> ContentProcessor {
        var rules = ContentProcessor.defaultRules
        if let currentUser = currentUser, !currentUser.fullName.isEmpty {
            rules.append(ReplaceTemplateUsernameRule(username: currentUser.fullName))
        }

        var injections = ContentProcessor.defaultInjections
        let cellAppearance = CourseInfoTabNewsCellView.Appearance()
        injections.append(FontInjection(font: cellAppearance.processedContentFont))
        injections.append(TextColorInjection(dynamicColor: cellAppearance.processedContentTextColor))

        return ContentProcessor(rules: rules, injections: injections)
    }
}
