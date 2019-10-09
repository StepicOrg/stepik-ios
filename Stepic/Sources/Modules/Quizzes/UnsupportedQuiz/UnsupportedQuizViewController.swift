import UIKit

protocol UnsupportedQuizViewControllerProtocol: class {
    func displayUnsupportedQuiz(viewModel: UnsupportedQuiz.UnsupportedQuizPresentation.ViewModel)
}

final class UnsupportedQuizViewController: UIViewController {
    private let interactor: UnsupportedQuizInteractorProtocol

    lazy var unsupportedQuizView = self.view as? UnsupportedQuizView

    init(interactor: UnsupportedQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UnsupportedQuizView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension UnsupportedQuizViewController: UnsupportedQuizViewControllerProtocol {
    func displayUnsupportedQuiz(viewModel: UnsupportedQuiz.UnsupportedQuizPresentation.ViewModel) {
        guard let encoededPath = viewModel.stepURLPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let stepURL = URL(string: encoededPath) else {
            return
        }

        WebControllerManager.sharedManager.presentWebControllerWithURL(
            stepURL,
            inController: self,
            withKey: "external link",
            allowsSafari: true,
            backButtonStyle: .close
        )
    }
}

extension UnsupportedQuizViewController: UnsupportedQuizViewDelegate {
    func unsupportedQuizViewDidClickOnActionButton(_ view: UnsupportedQuizView) {
        self.interactor.doUnsupportedQuizPresentation(request: .init())
    }
}
