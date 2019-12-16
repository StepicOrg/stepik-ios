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
            sizeInBytesByCourse: response.data.sizeInBytesByCourse,
            adaptiveCoursesIDs: response.data.adaptiveCoursesIDs
        )

        self.viewController?.displayDownloads(viewModel: .init(downloads: downloads))
    }

    func presentDeleteDownloadResult(response: Downloads.DeleteDownload.Response) {
        let downloads = self.makeViewModel(
            sizeInBytesByCourse: response.data.sizeInBytesByCourse,
            adaptiveCoursesIDs: response.data.adaptiveCoursesIDs
        )

        self.viewController?.displayDeleteDownloadResult(viewModel: .init(downloads: downloads))
    }

    // MARK: - Private API

    private func makeViewModel(
        sizeInBytesByCourse: [Course: UInt64],
        adaptiveCoursesIDs: Set<Course.IdType>
    ) -> [DownloadsItemViewModel] {
        sizeInBytesByCourse.map { item -> DownloadsItemViewModel in
            self.makeDownloadItemViewModel(
                course: item.key,
                sizeInBytes: item.value,
                availableAdaptiveCoursesIDs: adaptiveCoursesIDs
            )
        }.sorted { $0.id < $1.id }
    }

    private func makeDownloadItemViewModel(
        course: Course,
        sizeInBytes: UInt64,
        availableAdaptiveCoursesIDs: Set<Course.IdType>
    ) -> DownloadsItemViewModel {
        let formattedSize = FormatterHelper.megabytesInBytes(sizeInBytes)

        return DownloadsItemViewModel(
            id: course.id,
            coverImageURL: URL(string: course.coverURLString),
            isAdaptive: availableAdaptiveCoursesIDs.contains(course.id),
            title: course.title,
            subtitle: formattedSize
        )
    }
}
