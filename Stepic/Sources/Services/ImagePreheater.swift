import Foundation
import Nuke
import PromiseKit

protocol ImagePreheaterProtocol: AnyObject {
    func preheat(urls: [URL]) -> Guarantee<[Result<Void>]>
}

final class NukeImagePreheater: ImagePreheaterProtocol {
    private let imagePipeline: ImagePipeline
    private let maxConcurrentRequestCount: Int

    init(
        imagePipeline: ImagePipeline = .shared,
        maxConcurrentRequestCount: Int = 3
    ) {
        self.imagePipeline = imagePipeline
        self.maxConcurrentRequestCount = maxConcurrentRequestCount
    }

    func preheat(urls: [URL]) -> Guarantee<[Result<Void>]> {
        Guarantee { seal in
            if urls.isEmpty {
                return seal([])
            }

            var urlGenerator = urls.makeIterator()

            let generator = AnyIterator<Guarantee<Void?>> {
                guard let url = urlGenerator.next() else {
                    return nil
                }

                return Guarantee(self.loadImage(url: url), fallback: nil)
            }

            when(fulfilled: generator, concurrently: self.maxConcurrentRequestCount).done { results in
                seal(
                    results.map { $0 == nil ? .rejected(Error.loadImageFailed) : .fulfilled(()) }
                )
            }.catch { error in
                assert(false, "Should not happen")
                seal([Result.rejected(error)])
            }
        }
    }

    private func loadImage(url: URL) -> Promise<Void> {
        Promise { seal in
            self.imagePipeline.loadData(with: ImageRequest(url: url)) { result in
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
