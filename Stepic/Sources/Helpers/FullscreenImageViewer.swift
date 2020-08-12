import Agrume
import Nuke
import UIKit

final class FullscreenImageViewer {
    private init() {}

    static func show(image: UIImage, from presentingViewController: UIViewController) {
        let agrume = Agrume(image: image)
        agrume.show(from: presentingViewController)
    }

    static func show(url: URL, from presentingViewController: UIViewController) {
        let agrume = Agrume(url: url)
        agrume.download = { [weak agrume] (url, downloadCompletion) in
            guard let agrume = agrume else {
                return
            }

            if let cachedImageContainer = ImagePipeline.shared.cachedImage(for: url) {
                downloadCompletion(cachedImageContainer.image)
            } else {
                ImagePipeline.shared.loadImage(
                    with: url,
                    queue: .main,
                    progress: nil,
                    completion: { result in
                        switch result {
                        case .success(let imageResponse):
                            downloadCompletion(imageResponse.image)
                        case .failure:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(
                                    title: NSLocalizedString("Error", comment: ""),
                                    message: NSLocalizedString("FullscreenImageViewerErrorMessage", comment: ""),
                                    preferredStyle: .alert
                                )
                                alert.addAction(
                                    UIAlertAction(
                                        title: NSLocalizedString("FullscreenImageViewerErrorActionRetry", comment: ""),
                                        style: .default,
                                        handler: { _ in
                                            agrume.reload()
                                        }
                                    )
                                )
                                alert.addAction(
                                    UIAlertAction(
                                        title: NSLocalizedString("FullscreenImageViewerErrorActionClose", comment: ""),
                                        style: .cancel,
                                        handler: { _ in
                                            agrume.dismiss()
                                        }
                                    )
                                )
                                agrume.present(module: alert)
                            }
                            downloadCompletion(nil)
                        }
                    }
                )
            }
        }
        agrume.show(from: presentingViewController)
    }
}
