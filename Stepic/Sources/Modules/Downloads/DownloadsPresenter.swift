import UIKit

protocol DownloadsPresenterProtocol {
    func presentDownloads(response: Downloads.DownloadsLoad.Response)
}

// MARK: - DownloadsPresenter: DownloadsPresenterProtocol -

final class DownloadsPresenter: DownloadsPresenterProtocol {
    weak var viewController: DownloadsViewControllerProtocol?

    // MARK: - DownloadsPresenterProtocol

    func presentDownloads(response: Downloads.DownloadsLoad.Response) {
        let downloads = response.data.downloadedItemsByCourse.map { item -> DownloadsItemViewModel in
            let downloadedItemsSizeInBytes = item.value.reduce(0) { $0 + $1.sizeInBytes }
            return self.makeDownloadItemViewModel(course: item.key, sizeInBytes: downloadedItemsSizeInBytes)
        }

        self.viewController?.displayDownloads(viewModel: .init(downloads: downloads))
    }

    // MARK: - Private API

    private func makeDownloadItemViewModel(course: Course, sizeInBytes: UInt64) -> DownloadsItemViewModel {
        let sizeInMegabytes = max(1, sizeInBytes / 1024 / 1024)
        let formattedSize = "\(sizeInMegabytes) \(NSLocalizedString("Mb", comment: ""))"

        return DownloadsItemViewModel(
            uniqueIdentifier: "\(course.id)",
            coverImageURL: URL(string: course.coverURLString),
            title: course.title,
            subtitle: formattedSize
        )
    }
}
