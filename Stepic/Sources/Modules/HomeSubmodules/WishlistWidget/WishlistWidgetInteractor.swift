import Foundation
import PromiseKit

protocol WishlistWidgetInteractorProtocol {
    func doWishlistLoad(request: WishlistWidget.WishlistLoad.Request)
    func doFullscreenCourseListPresentation(request: WishlistWidget.FullscreenCourseListModulePresentation.Request)
}

final class WishlistWidgetInteractor: WishlistWidgetInteractorProtocol {
    private let presenter: WishlistWidgetPresenterProtocol
    private let provider: WishlistWidgetProviderProtocol

    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var didLoadFromCache = false
    private var didPresentWishlist = false

    init(
        presenter: WishlistWidgetPresenterProtocol,
        provider: WishlistWidgetProviderProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self
    }

    func doWishlistLoad(request: WishlistWidget.WishlistLoad.Request) {
        self.fetchWishlistInAppropriateMode().done { data in
            let isCacheEmpty = !self.didLoadFromCache && data.isEmpty

            if !isCacheEmpty {
                self.didPresentWishlist = true
                self.presenter.presentWishlist(response: .init(result: .success(data)))
            }

            if !self.didLoadFromCache {
                self.didLoadFromCache = true
                self.doWishlistLoad(request: .init())
            }
        }.catch { error in
            switch error as? Error {
            case .some(.remoteFetchFailed):
                if self.didLoadFromCache && !self.didPresentWishlist {
                    self.presenter.presentWishlist(response: .init(result: .failure(error)))
                }
            case .some(.cacheFetchFailed):
                break
            default:
                self.presenter.presentWishlist(response: .init(result: .failure(error)))
            }
        }
    }

    func doFullscreenCourseListPresentation(request: WishlistWidget.FullscreenCourseListModulePresentation.Request) {
        self.provider.fetchWishlistCoursesIDs(from: .cache).done { coursesIDs in
            self.presenter.presentFullscreenCourseList(response: .init(coursesIDs: coursesIDs))
        }.cauterize()
    }

    private func fetchWishlistInAppropriateMode() -> Promise<WishlistWidget.WishlistLoad.Data> {
        Promise { seal in
            firstly {
                self.didLoadFromCache
                    ? self.provider.fetchWishlistCoursesIDs(from: .remote)
                    : self.provider.fetchWishlistCoursesIDs(from: .cache)
            }.done { coursesIDs in
                let response = WishlistWidget.WishlistLoad.Data(coursesIDs: coursesIDs)
                seal.fulfill(response)
            }.catch { error in
                switch error as? WishlistWidgetProvider.Error {
                case .some(.cacheFetchFailed):
                    seal.reject(Error.cacheFetchFailed)
                case .some(.remoteFetchFailed):
                    seal.reject(Error.remoteFetchFailed)
                default:
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

extension WishlistWidgetInteractor: WishlistWidgetInputProtocol {
    func refreshWishlist() {
        self.doWishlistLoad(request: .init())
    }
}

extension WishlistWidgetInteractor: DataBackUpdateServiceDelegate {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport refreshedTarget: DataBackUpdateTarget
    ) {
        guard case .wishlist(let coursesIDs) = refreshedTarget else {
            return
        }

        self.presenter.presentWishlist(response: .init(result: .success(.init(coursesIDs: coursesIDs))))
    }

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) {}
}
