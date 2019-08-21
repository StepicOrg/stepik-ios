import Agrume
import UIKit

protocol NewSortingQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewSortingQuiz.ReplyLoad.ViewModel)
}

final class NewSortingQuizViewController: UIViewController {
    private let interactor: NewSortingQuizInteractorProtocol

    lazy var newSortingQuizView = self.view as? NewSortingQuizView

    // Store options for smart quiz reset
    private var lastOptionDataset: [String] = []

    init(interactor: NewSortingQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewSortingQuizView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension NewSortingQuizViewController: NewSortingQuizViewControllerProtocol {
    func displayReply(viewModel: NewSortingQuiz.ReplyLoad.ViewModel) {
        if self.lastOptionDataset != viewModel.data.options.map { $0.text } {
            self.lastOptionDataset = viewModel.data.options.map { $0.text }
            self.newSortingQuizView?.set(options: viewModel.data.options)
        }

        self.newSortingQuizView?.isEnabled = viewModel.data.isEnabled
    }
}

extension NewSortingQuizViewController: NewSortingQuizViewDelegate {
    func newSortingQuizView(
        _ view: NewSortingQuizView,
        didMoveOption option: NewSortingQuiz.Option,
        atIndex sourceIndex: Int,
        toIndex destinationIndex: Int
    ) {
        guard let options = self.newSortingQuizView?.options else {
            return
        }

        self.interactor.doReplyUpdate(request: .init(options: options))
    }

    func newSortingQuizView(_ view: NewSortingQuizView, didRequestOpenURL url: URL) {
        let scheme = url.scheme?.lowercased() ?? ""
        if ["http", "https"].contains(scheme) {
            WebControllerManager.sharedManager.presentWebControllerWithURL(
                url,
                inController: self,
                withKey: "external link",
                allowsSafari: true,
                backButtonStyle: .done
            )
        }
    }

    func newSortingQuizView(_ view: NewSortingQuizView, didRequestFullscreenImage url: URL) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }
}
