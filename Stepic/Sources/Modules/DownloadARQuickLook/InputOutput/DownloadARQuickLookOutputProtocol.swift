import Foundation

protocol DownloadARQuickLookOutputProtocol: AnyObject {
    func handleDidDownloadARQuickLook(storedURL: URL)
    func handleDidFailDownloadARQuickLook(error: Error)
}
