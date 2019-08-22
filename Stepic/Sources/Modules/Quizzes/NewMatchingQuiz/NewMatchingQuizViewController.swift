import Agrume
import UIKit

protocol NewMatchingQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewMatchingQuiz.ReplyLoad.ViewModel)
}

final class NewMatchingQuizViewController: UIViewController {
    private let interactor: NewMatchingQuizInteractorProtocol

    lazy var newMatchingQuizView = self.view as? NewMatchingQuizView

    init(interactor: NewMatchingQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewMatchingQuizView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension NewMatchingQuizViewController: NewMatchingQuizViewControllerProtocol {
    func displayReply(viewModel: NewMatchingQuiz.ReplyLoad.ViewModel) {
        self.newMatchingQuizView?.title = viewModel.data.title
        self.newMatchingQuizView?.set(items: viewModel.data.items)
        self.newMatchingQuizView?.isEnabled = viewModel.data.isEnabled
    }
}

extension NewMatchingQuizViewController: NewMatchingQuizViewDelegate {
    func newMatchingQuizView(
        _ view: NewMatchingQuizView,
        didMoveItem item: NewMatchingQuiz.MatchItem,
        atIndex sourceIndex: Int,
        toIndex destinationIndex: Int
    ) {
        guard let items = self.newMatchingQuizView?.items else {
            return
        }

        self.interactor.doReplyUpdate(request: .init(items: items))
    }

    func newMatchingQuizView(_ view: NewMatchingQuizView, didRequestOpenURL url: URL) {
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

    func newMatchingQuizView(_ view: NewMatchingQuizView, didRequestFullscreenImage url: URL) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }
}
