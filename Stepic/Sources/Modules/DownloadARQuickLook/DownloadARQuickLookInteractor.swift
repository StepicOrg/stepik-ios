import Foundation
import PromiseKit

protocol DownloadARQuickLookInteractorProtocol {
    func doStartDownload(request: DownloadARQuickLook.StartDownload.Request)
    func doCancelDownload(request: DownloadARQuickLook.CancelDownload.Request)
}

final class DownloadARQuickLookInteractor: DownloadARQuickLookInteractorProtocol {
    weak var moduleOutput: DownloadARQuickLookOutputProtocol?

    private let url: URL
    private let presenter: DownloadARQuickLookPresenterProtocol

    private let downloadingService: DownloadingServiceProtocol
    private let arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol

    private var activeTaskID: DownloaderTaskProtocol.IDType?

    init(
        url: URL,
        presenter: DownloadARQuickLookPresenterProtocol,
        downloadingService: DownloadingServiceProtocol,
        arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol
    ) {
        self.url = url
        self.presenter = presenter
        self.downloadingService = downloadingService
        self.arQuickLookStoredFileManager = arQuickLookStoredFileManager

        self.subscribeOnDownloadEvents()
    }

    func doStartDownload(request: DownloadARQuickLook.StartDownload.Request) {
        do {
            let destinationFilename = self.arQuickLookStoredFileManager.makeARQuickLookFilenameFromDownloadURL(self.url)
            self.activeTaskID = try self.downloadingService.download(url: self.url, destination: destinationFilename)
        } catch {
            self.moduleOutput?.handleDidFailDownloadARQuickLook(error: error)
        }
    }

    func doCancelDownload(request: DownloadARQuickLook.CancelDownload.Request) {
        if let activeTaskID = self.activeTaskID {
            try? self.downloadingService.cancelDownload(taskID: activeTaskID)
        }

        self.presenter.presentCancelDownloadResult(response: .init())
    }

    private func subscribeOnDownloadEvents() {
        self.downloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                self?.handleDownloadingEvent(event)
            }
        }
    }

    private func handleDownloadingEvent(_ event: DownloadingServiceEvent) {
        switch event.state {
        case .active(let progress):
            let progress = min(1.0, max(0.0, progress))
            self.presenter.presentDownloadProgressUpdate(response: .init(progress: progress))
        case .completed(let storedURL):
            self.presenter.presentDownloadProgressUpdate(response: .init(progress: 1.0))
            self.presenter.presentCompleteDownloadResult(response: .init())
            self.moduleOutput?.handleDidDownloadARQuickLook(storedURL: storedURL)
        case .error(let error):
            if case DownloadingService.Error.downloadingStopped = error {
                return
            }
            self.presenter.presentFailDownloadResult(response: .init(error: error))
            self.moduleOutput?.handleDidFailDownloadARQuickLook(error: error)
        }
    }
}
