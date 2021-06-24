import UIKit

protocol CourseBenefitDetailViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CourseBenefitDetail.SomeAction.ViewModel)
}

final class CourseBenefitDetailViewController: UIViewController {
    private let interactor: CourseBenefitDetailInteractorProtocol

    init(interactor: CourseBenefitDetailInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseBenefitDetailView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseBenefitDetailViewController: CourseBenefitDetailViewControllerProtocol {
    func displaySomeActionResult(viewModel: CourseBenefitDetail.SomeAction.ViewModel) {}
}
