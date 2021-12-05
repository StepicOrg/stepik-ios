import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response)
    func presentCheckPromoCodeResult(response: CourseInfoPurchaseModal.CheckPromoCode.Response)
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

    // MARK: Private API

    private func makeModalViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalViewModel {
        let priceViewModel = self.makePriceViewModel(course: course, mobileTier: mobileTier)

        return CourseInfoPurchaseModalViewModel(
            courseTitle: course.title,
            courseCoverImageURL: URL(string: course.coverURLString),
            price: priceViewModel,
            isInWishList: course.isInWishlist
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
}
