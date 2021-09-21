import PromiseKit
import UIKit

protocol CourseInfoTabNewsPresenterProtocol {
    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response)
    func presentNextCourseNews(response: CourseInfoTabNews.NextNewsLoad.Response)
}

final class CourseInfoTabNewsPresenter: CourseInfoTabNewsPresenterProtocol {
    weak var viewController: CourseInfoTabNewsViewControllerProtocol?

    private lazy var contentProcessor: ContentProcessor = {
        let cellAppearance = CourseInfoTabNewsCellView.Appearance()
        return ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: cellAppearance.processedContentFont),
                TextColorInjection(dynamicColor: cellAppearance.processedContentTextColor)
            ]
        )
    }()

    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response) {
        switch response.result {
        case .success(let data):
            self.makeNewsViewModels(data.announcements).done { viewModels in
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
            self.makeNewsViewModels(data.announcements).done { viewModels in
                let data = CourseInfoTabNews.NewsResultData(news: viewModels, hasNextPage: data.hasNextPage)
                self.viewController?.displayNextCourseNews(viewModel: .init(state: .result(data: data)))
            }
        case .failure:
            self.viewController?.displayNextCourseNews(viewModel: .init(state: .error))
        }
    }

    // MARK: Private API

    private func makeNewsViewModels(
        _ announcements: [AnnouncementPlainObject]
    ) -> Guarantee<[CourseInfoTabNewsViewModel]> {
        Guarantee { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                let viewModels = announcements.map(self.makeViewModel(_:))

                DispatchQueue.main.async {
                    seal(viewModels)
                }
            }
        }
    }

    private func makeViewModel(_ announcement: AnnouncementPlainObject) -> CourseInfoTabNewsViewModel {
        let formattedDate = FormatterHelper.dateStringWithFullMonthAndYear(announcement.sentDate ?? Date())

        let processedContent = self.contentProcessor.processContent(announcement.text)

        return CourseInfoTabNewsViewModel(
            uniqueIdentifier: "\(announcement.id)",
            formattedDate: formattedDate,
            processedContent: processedContent
        )
    }
}
