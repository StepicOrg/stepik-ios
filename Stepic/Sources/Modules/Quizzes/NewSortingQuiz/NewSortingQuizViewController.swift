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
        self.view = view
    }
}

extension NewSortingQuizViewController: NewSortingQuizViewControllerProtocol {
    func displayReply(viewModel: NewSortingQuiz.ReplyLoad.ViewModel) {
        if self.lastOptionDataset != viewModel.data.options {
            self.lastOptionDataset = viewModel.data.options
            self.newSortingQuizView?.set(options: viewModel.data.options)
        }

        self.newSortingQuizView?.isEnabled = viewModel.data.isEnabled
    }
}
