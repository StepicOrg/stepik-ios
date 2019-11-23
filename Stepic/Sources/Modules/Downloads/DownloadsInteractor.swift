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

    private var currentCachedStepsByCourse: [Course: [Step]] = [:]

    init(
        presenter: DownloadsPresenterProtocol,
        provider: DownloadsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: - DownloadsInteractorProtocol

    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request) {
        self.provider.fetchCachedSteps().done { cachedStepsByCourse in
            self.currentCachedStepsByCourse = cachedStepsByCourse
            self.presenter.presentDownloads(response: .init(data: self.makeDownloadsDataFromCurrentData()))
        }
    }

    func doDeleteDownload(request: Downloads.DeleteDownload.Request) {
        guard let (course, steps) = self.currentCachedStepsByCourse.first(where: { $0.key.id == request.id }) else {
            return self.presenter.presentDeleteDownloadResult(
                response: .init(data: self.makeDownloadsDataFromCurrentData())
            )
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.Course.Downloads.deleted, parameters: ["source": "downloads"])
        AmplitudeAnalyticsEvents.Downloads.deleted(content: .course, source: .downloads).send()

        self.provider.deleteSteps(steps).done { succeededIDs, failedIDs in
            if succeededIDs.count == steps.count {
                self.currentCachedStepsByCourse[course] = nil
            } else {
                self.currentCachedStepsByCourse[course] = self.currentCachedStepsByCourse[course]?.filter {
                    failedIDs.contains($0.id)
                }
            }

            self.presenter.presentDeleteDownloadResult(response: .init(data: self.makeDownloadsDataFromCurrentData()))
        }
    }

    // MARK: - Private API

    private func makeDownloadsDataFromCurrentData() -> Downloads.DownloadsData {
        var downloadedItemsByCourse: [Course: [Downloads.DownloadsData.Item]] = [:]

        self.currentCachedStepsByCourse.forEach { course, steps in
            downloadedItemsByCourse[course] = steps.map { step in
                var stepSizeInBytes: UInt64
                if step.block.type == .video,
                   let videoID = step.block.video?.id {
                    stepSizeInBytes = self.provider.getVideoFileSize(videoID: videoID)
                } else {
                    stepSizeInBytes = UInt64((step.block.text ?? "").utf8.count)
                }

                return .init(sizeInBytes: stepSizeInBytes)
            }
        }

        let availableAdaptiveCoursesIDs = self.currentCachedStepsByCourse.keys.compactMap {
            self.provider.isAdaptiveCourse(courseID: $0.id) ? $0.id : nil
        }

        return .init(
            downloadedItemsByCourse: downloadedItemsByCourse,
            adaptiveCoursesIDs: availableAdaptiveCoursesIDs
        )
    }
}
