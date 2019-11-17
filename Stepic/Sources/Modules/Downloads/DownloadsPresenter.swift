import UIKit

protocol DownloadsPresenterProtocol {
    func presentDownloads(response: Downloads.DownloadsLoad.Response)
    func presentDeleteDownloadResult(response: Downloads.DeleteDownload.Response)
}

// MARK: - DownloadsPresenter: DownloadsPresenterProtocol -

final class DownloadsPresenter: DownloadsPresenterProtocol {
    weak var viewController: DownloadsViewControllerProtocol?

    // MARK: - DownloadsPresenterProtocol

    func presentDownloads(response: Downloads.DownloadsLoad.Response) {
        let downloads = self.makeViewModel(
            downloadedItems: response.data.downloadedItemsByCourse,
            adaptiveCoursesIDs: response.data.adaptiveCoursesIDs
        )

        self.viewController?.displayDownloads(viewModel: .init(downloads: downloads))
    }

    func presentDeleteDownloadResult(response: Downloads.DeleteDownload.Response) {
        let downloads = self.makeViewModel(
            downloadedItems: response.data.downloadedItemsByCourse,
            adaptiveCoursesIDs: response.data.adaptiveCoursesIDs
        )

        self.viewController?.displayDeleteDownloadResult(viewModel: .init(downloads: downloads))
    }

    // MARK: - Private API

    private func makeViewModel(
        downloadedItems: [Course: [Downloads.DownloadsData.Item]],
        adaptiveCoursesIDs: [Course.IdType]
    ) -> [DownloadsItemViewModel] {
        return downloadedItems.map { item -> DownloadsItemViewModel in
            let downloadedItemsSizeInBytes = item.value.reduce(0) { $0 + $1.sizeInBytes }
            return self.makeDownloadItemViewModel(
                course: item.key,
                sizeInBytes: downloadedItemsSizeInBytes,
                availableAdaptiveCoursesIDs: adaptiveCoursesIDs
            )
        }.sorted { $0.id < $1.id }
    }

    private func makeDownloadItemViewModel(
        course: Course,
        sizeInBytes: UInt64,
        availableAdaptiveCoursesIDs: [Course.IdType]
    ) -> DownloadsItemViewModel {
        let sizeInMegabytes = max(1, sizeInBytes / 1024 / 1024)
        let formattedSize = "\(sizeInMegabytes) \(NSLocalizedString("Mb", comment: ""))"

        return DownloadsItemViewModel(
            id: course.id,
            coverImageURL: URL(string: course.coverURLString),
            isAdaptive: availableAdaptiveCoursesIDs.contains(course.id),
            title: course.title,
            subtitle: formattedSize
        )
    }
}
