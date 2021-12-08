import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response)
    func presentCheckPromoCodeResult(response: CourseInfoPurchaseModal.CheckPromoCode.Response)
    func presentAddCourseToWishlistResult(response: CourseInfoPurchaseModal.AddCourseToWishlist.Response)
}

final class CourseInfoPurchaseModalPresenter: CourseInfoPurchaseModalPresenterProtocol {
    weak var viewController: CourseInfoPurchaseModalViewControllerProtocol?

    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeModalViewModel(course: data.course, mobileTier: data.mobileTier)
            self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayModal(viewModel: .init(state: .error))
        }
    }

    func presentCheckPromoCodeResult(response: CourseInfoPurchaseModal.CheckPromoCode.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makePriceViewModel(course: data.course, mobileTier: data.mobileTier)
            self.viewController?.displayCheckPromoCodeResult(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCheckPromoCodeResult(viewModel: .init(state: .error))
        }
    }

    func presentAddCourseToWishlistResult(response: CourseInfoPurchaseModal.AddCourseToWishlist.Response) {
        switch response.state {
        case .loading:
            let viewModel = self.makeWishlistViewModel(isInWishlist: false, isLoading: true)
            self.viewController?.displayAddCourseToWishlistResult(viewModel: .init(state: .loading(viewModel)))
        case .error:
            let message = NSLocalizedString("CourseInfoAddToWishlistFailureMessage", comment: "")
            self.viewController?.displayAddCourseToWishlistResult(viewModel: .init(state: .error(message: message)))
        case .success:
            let message = NSLocalizedString("CourseInfoAddToWishlistSuccessMessage", comment: "")
            let viewModel = self.makeWishlistViewModel(isInWishlist: true, isLoading: false)
            self.viewController?.displayAddCourseToWishlistResult(
                viewModel: .init(state: .result(message: message, data: viewModel))
            )
        }
    }

    // MARK: Private API

    private func makeModalViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalViewModel {
        let priceViewModel = self.makePriceViewModel(course: course, mobileTier: mobileTier)
        let wishlistViewModel = self.makeWishlistViewModel(isInWishlist: course.isInWishlist)

        return CourseInfoPurchaseModalViewModel(
            courseTitle: course.title,
            courseCoverImageURL: URL(string: course.coverURLString),
            price: priceViewModel,
            wishlist: wishlistViewModel
        )
    }

    private func makePriceViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalPriceViewModel {
        let displayPrice = mobileTier.priceTierDisplayPrice ?? course.displayPrice ?? "None"
        let promoDisplayPrice = mobileTier.promoTierDisplayPrice

        return CourseInfoPurchaseModalPriceViewModel(
            displayPrice: displayPrice,
            promoDisplayPrice: promoDisplayPrice,
            promoCodeName: mobileTier.promoCodeName
        )
    }

    private func makeWishlistViewModel(
        isInWishlist: Bool,
        isLoading: Bool = false
    ) -> CourseInfoPurchaseModalWishlistViewModel {
        let title: String = {
            if isLoading {
                return NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddingToWishlistTitle", comment: "")
            }
            return isInWishlist
                ? NSLocalizedString("CourseInfoPurchaseModalWishlistButtonInWishlistTitle", comment: "")
                : NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddToWishlistTitle", comment: "")
        }()

        return CourseInfoPurchaseModalWishlistViewModel(
            title: title,
            isInWishlist: isInWishlist,
            isLoading: isLoading
        )
    }
}
