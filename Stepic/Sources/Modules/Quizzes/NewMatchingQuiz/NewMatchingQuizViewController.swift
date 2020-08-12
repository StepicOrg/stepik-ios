import UIKit

protocol NewMatchingQuizViewControllerProtocol: AnyObject {
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
        self.newMatchingQuizView?.isEnabled = viewModel.data.finalState == nil || viewModel.data.finalState == .wrong
        self.newMatchingQuizView?.shouldShowShadows = viewModel.data.finalState != .correct
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
            WebControllerManager.shared.presentWebControllerWithURL(
                url,
                inController: self,
                withKey: .externalLink,
                allowsSafari: true,
                backButtonStyle: .done
            )
        }
    }

    func newMatchingQuizView(_ view: NewMatchingQuizView, didRequestFullscreenImage url: URL) {
        FullscreenImageViewer.show(url: url, from: self)
    }
}
