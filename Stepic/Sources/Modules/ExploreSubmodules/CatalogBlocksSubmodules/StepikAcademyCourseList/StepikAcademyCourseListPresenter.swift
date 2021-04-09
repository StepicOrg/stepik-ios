import UIKit

protocol StepikAcademyCourseListPresenterProtocol {
    func presentCourseList(response: StepikAcademyCourseList.CourseListLoad.Response)
}

final class StepikAcademyCourseListPresenter: StepikAcademyCourseListPresenterProtocol {
    weak var viewController: StepikAcademyCourseListViewControllerProtocol?

    func presentCourseList(response: StepikAcademyCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.map(self.makeViewModel)
            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    private func makeViewModel(
        contentItem: SpecializationsCatalogBlockContentItem
    ) -> StepikAcademyCourseListWidgetViewModel {
        let formattedDiscount: String? = {
            guard let discountValue = Float(contentItem.discountString),
                  discountValue > 0 else {
                return nil
            }

            return FormatterHelper.price(discountValue, currencyCode: contentItem.currencyString)
        }()

        let formattedPrice = FormatterHelper.price(
            Float(contentItem.priceString) ?? 0,
            currencyCode: contentItem.currencyString
        )

        return StepikAcademyCourseListWidgetViewModel(
            uniqueIdentifier: "\(contentItem.id)",
            title: contentItem.title,
            duration: contentItem.durationString,
            discount: formattedDiscount,
            price: formattedPrice
        )
    }
}
