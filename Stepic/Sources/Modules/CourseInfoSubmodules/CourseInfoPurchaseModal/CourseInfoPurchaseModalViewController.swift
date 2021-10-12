import UIKit

protocol CourseInfoPurchaseModalViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CourseInfoPurchaseModal.SomeAction.ViewModel)
}

final class CourseInfoPurchaseModalViewController: UIViewController {
    private let interactor: CourseInfoPurchaseModalInteractorProtocol

    init(interactor: CourseInfoPurchaseModalInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseInfoPurchaseModalView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewControllerProtocol {
    func displaySomeActionResult(viewModel: CourseInfoPurchaseModal.SomeAction.ViewModel) {}
}
