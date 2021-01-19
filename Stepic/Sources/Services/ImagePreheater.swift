import Foundation
import Nuke
import PromiseKit

protocol ImagePreheaterProtocol: AnyObject {
    func preheat(urls: [URL], concurrently: Int) -> Guarantee<[Result<Void>]>
}

extension ImagePreheaterProtocol {
    func preheat(urls: [URL]) -> Guarantee<[Result<Void>]> {
        self.preheat(urls: urls, concurrently: 0)
    }
}

final class NukeImagePreheater: ImagePreheaterProtocol {
    private let imagePipeline: ImagePipeline

    init(imagePipeline: ImagePipeline = .shared) {
        self.imagePipeline = imagePipeline
    }

    func preheat(urls: [URL], concurrently: Int) -> Guarantee<[Result<Void>]> {
        if urls.isEmpty {
            return .value([])
        }

        if concurrently > 0 {
            return self.loadImages(urls: urls, concurrently: concurrently)
        } else {
            return self.loadImages(urls: urls)
        }
    }

    private func loadImages(urls: [URL], concurrently: Int) -> Guarantee<[Result<Void>]> {
        Guarantee { seal in
            var urlGenerator = urls.makeIterator()

            let generator = AnyIterator<Guarantee<Void?>> {
                guard let url = urlGenerator.next() else {
                    return nil
                }

                return Guarantee(self.loadImage(url: url), fallback: nil)
            }

            when(fulfilled: generator, concurrently: concurrently).done { results in
                seal(
                    results.map { $0 == nil ? .rejected(Error.loadImageFailed) : .fulfilled(()) }
                )
            }.catch { error in
                assert(false, "Should not happen")
                seal([Result.rejected(error)])
            }
        }
    }

    private func loadImages(urls: [URL]) -> Guarantee<[Result<Void>]> {
        let loadImagesPromises = urls.map { self.loadImage(url: $0) }
        return when(resolved: loadImagesPromises)
    }

    private func loadImage(url: URL) -> Promise<Void> {
        Promise { seal in
            self.imagePipeline.loadImage(with: ImageRequest(url: url)) { result in
                switch result {
                case .success:
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case loadImageFailed
    }
}
