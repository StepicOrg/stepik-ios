import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response)
}

final class CourseInfoPurchaseModalPresenter: CourseInfoPurchaseModalPresenterProtocol {
    weak var viewController: CourseInfoPurchaseModalViewControllerProtocol?

    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(course: data.course, mobileTier: data.mobileTier)
            self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayModal(viewModel: .init(state: .error))
        }
    }

    // MARK: Private API

    private func makeViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalViewModel {
        let displayPrice = mobileTier.priceTierDisplayPrice ?? course.displayPrice ?? "None"
        let promoDisplayPrice = mobileTier.promoTierDisplayPrice

        return CourseInfoPurchaseModalViewModel(
            courseTitle: course.title,
            courseCoverImageURL: URL(string: course.coverURLString),
            displayPrice: displayPrice,
            promoDisplayPrice: promoDisplayPrice,
            isInWishList: course.isInWishlist
        )
    }
}
