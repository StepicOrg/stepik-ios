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
            self.makeNewsViewModels(
                data.announcements,
                course: data.course,
                currentUser: data.currentUser
            ).done { viewModels in
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
            self.makeNewsViewModels(
                data.announcements,
                course: data.course,
                currentUser: data.currentUser
            ).done { viewModels in
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
        course: Course,
        currentUser: User?
    ) -> Guarantee<[CourseInfoTabNewsViewModel]> {
        Guarantee { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                let contentProcessor = self.makeContentProcessor(currentUser: currentUser)
                let viewModels = announcements.map {
                    self.makeViewModel($0, course: course, contentProcessor: contentProcessor)
                }

                DispatchQueue.main.async {
                    seal(viewModels)
                }
            }
        }
    }

    private func makeViewModel(
        _ announcement: AnnouncementPlainObject,
        course: Course,
        contentProcessor: ContentProcessor
    ) -> CourseInfoTabNewsViewModel {
        let formattedDate = self.makeDateRepresentation(announcement: announcement, course: course)
        let processedContent = contentProcessor.processContent(announcement.text)
        let badgeViewModel = self.makeBadgeViewModel(announcement: announcement, course: course)
        let statisticsViewModel = self.makeStatisticsViewModel(announcement: announcement, course: course)

        return CourseInfoTabNewsViewModel(
            uniqueIdentifier: "\(announcement.id)",
            formattedDate: formattedDate,
            subject: announcement.subject.trimmed(),
            processedContent: processedContent,
            badge: badgeViewModel,
            statistics: statisticsViewModel
        )
    }

    private func makeDateRepresentation(announcement: AnnouncementPlainObject, course: Course) -> String {
        let defaultDate = (announcement.sentDate ?? announcement.createDate) ?? Date()

        guard let status = announcement.status else {
            return FormatterHelper.dateStringWithFullMonthAndYear(defaultDate)
        }

        if !course.canCreateAnnouncements {
            if announcement.isActiveEvent, let noticeDate = announcement.noticeDates.first {
                return FormatterHelper.dateStringWithFullMonthAndYear(noticeDate)
            }
        } else {
            switch status {
            case .composing:
                if let displayedStartDate = announcement.displayedStartDate {
                    let formattedStartDate = FormatterHelper.dateStringWithFullMonthAndYear(displayedStartDate)
                    if announcement.isActiveEvent {
                        return String(
                            format: NSLocalizedString("CourseInfoTabNewsDateOnEventComposing", comment: ""),
                            arguments: [formattedStartDate]
                        )
                    } else {
                        return formattedStartDate
                    }
                }
            case .scheduled:
                if let displayedStartDate = announcement.displayedStartDate {
                    let formattedStartDate = FormatterHelper.dateStringWithFullMonthAndYear(displayedStartDate)
                    if announcement.isActiveEvent {
                        return String(
                            format: NSLocalizedString("CourseInfoTabNewsDateOnEventSending", comment: ""),
                            arguments: [formattedStartDate]
                        )
                    } else {
                        return String(
                            format: NSLocalizedString("CourseInfoTabNewsDateOneTimeScheduled", comment: ""),
                            arguments: [FormatterHelper.dateStringWithFullMonthAndYear(displayedStartDate)]
                        )
                    }
                }
            case .queueing, .queued, .sending:
                if let displayedStartDate = announcement.displayedStartDate {
                    let formattedStartDate = FormatterHelper.dateStringWithFullMonthAndYear(displayedStartDate)
                    if announcement.isActiveEvent {
                        return String(
                            format: NSLocalizedString("CourseInfoTabNewsDateOnEventSending", comment: ""),
                            arguments: [formattedStartDate]
                        )
                    } else {
                        return String(
                            format: NSLocalizedString("CourseInfoTabNewsDateOneTimeSending", comment: ""),
                            arguments: [formattedStartDate]
                        )
                    }
                }
            case .sent, .aborted:
                if let displayedStartDate = announcement.displayedStartDate {
                    let formattedStartDate = FormatterHelper.dateStringWithFullMonthAndYear(displayedStartDate)
                    if announcement.isActiveEvent {
                        if let displayedFinishDate = announcement.displayedFinishDate {
                            return String(
                                format: NSLocalizedString("CourseInfoTabNewsDateOnEventSent", comment: ""),
                                arguments: [
                                    formattedStartDate,
                                    FormatterHelper.dateStringWithFullMonthAndYear(displayedFinishDate)
                                ]
                            )
                        }
                    } else {
                        return formattedStartDate
                    }
                }
            }
        }

        return FormatterHelper.dateStringWithFullMonthAndYear(defaultDate)
    }

    private func makeBadgeViewModel(
        announcement: AnnouncementPlainObject,
        course: Course
    ) -> CourseInfoTabNewsBadgeViewModel? {
        guard course.canCreateAnnouncements,
              let status = announcement.status else {
            return nil
        }

        return CourseInfoTabNewsBadgeViewModel(
            status: status,
            isOneTimeEvent: announcement.isOneTimeEvent,
            isActiveEvent: announcement.isActiveEvent
        )
    }

    private func makeStatisticsViewModel(
        announcement: AnnouncementPlainObject,
        course: Course
    ) -> CourseInfoTabNewsStatisticsViewModel? {
        guard course.canCreateAnnouncements,
              let status = announcement.status else {
            return nil
        }

        switch status {
        case .composing:
            return nil
        case .scheduled:
            if !announcement.isActiveEvent {
                return nil
            }
        case .queueing, .queued, .sending, .sent, .aborted:
            break
        }

        return CourseInfoTabNewsStatisticsViewModel(
            publishCount: announcement.publishCount ?? 0,
            queueCount: announcement.queueCount ?? 0,
            sentCount: announcement.sentCount ?? 0,
            openCount: announcement.openCount ?? 0,
            clickCount: announcement.clickCount ?? 0
        )
    }

    private func makeContentProcessor(currentUser: User?) -> ContentProcessor {
        var rules = ContentProcessor.defaultRules
        if let currentUser = currentUser, !currentUser.fullName.isEmpty {
            rules.append(
                ReplaceTemplateUsernameRule(
                    shortName: currentUser.shortName,
                    fullName: FormatterHelper.username(currentUser)
                )
            )
        }

        var injections = ContentProcessor.defaultInjections
        let cellAppearance = CourseInfoTabNewsCellView.Appearance()
        injections.append(FontInjection(font: cellAppearance.processedContentFont))
        injections.append(TextColorInjection(dynamicColor: cellAppearance.processedContentTextColor))

        return ContentProcessor(rules: rules, injections: injections)
    }
}
