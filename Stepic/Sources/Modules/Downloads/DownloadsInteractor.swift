import Foundation
import PromiseKit

protocol DownloadsInteractorProtocol {
    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request)
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

    // MARK: - Private API

    private func makeDownloadsDataFromCurrentData() -> Downloads.DownloadsData {
        var downloadedItemsByCourse: [Course: [Downloads.DownloadsData.Item]] = [:]

        self.currentCachedStepsByCourse.forEach { course, steps in
            downloadedItemsByCourse[course] = steps.map { step in
                var stepSizeInBytes: UInt64
                if step.block.type == .Video,
                   let videoID = step.block.video?.id {
                    stepSizeInBytes = self.provider.getVideoFileSize(videoID: videoID)
                } else {
                    stepSizeInBytes = UInt64((step.block.text ?? "").utf8.count)
                }

                return .init(sizeInBytes: stepSizeInBytes)
            }
        }

        return .init(downloadedItemsByCourse: downloadedItemsByCourse)
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case something
    }
}
