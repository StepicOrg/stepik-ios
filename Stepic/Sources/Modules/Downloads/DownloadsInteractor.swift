import Foundation
import PromiseKit

protocol DownloadsInteractorProtocol {
    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request)
    func doDeleteDownload(request: Downloads.DeleteDownload.Request)
}

// MARK: - DownloadsInteractor: DownloadsInteractorProtocol -

final class DownloadsInteractor: DownloadsInteractorProtocol {
    private let presenter: DownloadsPresenterProtocol
    private let provider: DownloadsProviderProtocol
    private let analytics: Analytics

    private var currentCachedCourses: [Course] = []

    init(
        presenter: DownloadsPresenterProtocol,
        provider: DownloadsProviderProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
    }

    // MARK: - DownloadsInteractorProtocol

    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request) {
        self.provider.fetchCachedCourses().done { cachedCourses in
            self.currentCachedCourses = cachedCourses
            self.presenter.presentDownloads(response: .init(data: self.makeDownloadsDataFromCurrentData()))
        }
    }

    func doDeleteDownload(request: Downloads.DeleteDownload.Request) {
        guard let course = self.currentCachedCourses.first(where: { $0.id == request.id }) else {
            return self.presenter.presentDeleteDownloadResult(
                response: .init(data: self.makeDownloadsDataFromCurrentData())
            )
        }

        self.analytics.send(.downloadsDownloadDeleted(content: .course, source: .downloads))

        self.provider.deleteCachedCourses([course]).then {
            self.provider.fetchCachedCourses()
        }.done { cachedCourses in
            self.currentCachedCourses = cachedCourses
            self.presenter.presentDeleteDownloadResult(response: .init(data: self.makeDownloadsDataFromCurrentData()))
        }
    }

    // MARK: - Private API

    private func makeDownloadsDataFromCurrentData() -> Downloads.DownloadsData {
        let sizeInBytesByCourse = Dictionary(
            uniqueKeysWithValues: self.currentCachedCourses.map {
                ($0, self.provider.getCourseSize($0))
            }
        )

        let adaptiveCoursesIDs = Set(
            self.currentCachedCourses
                .filter { self.provider.isAdaptiveCourse(courseID: $0.id) }
                .map { $0.id }
        )

        return .init(
            sizeInBytesByCourse: sizeInBytesByCourse,
            adaptiveCoursesIDs: adaptiveCoursesIDs
        )
    }
}
