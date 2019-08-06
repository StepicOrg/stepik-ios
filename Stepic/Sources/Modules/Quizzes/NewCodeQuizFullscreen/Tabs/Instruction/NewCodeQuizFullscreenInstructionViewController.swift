import Agrume
import UIKit

final class NewCodeQuizFullscreenInstructionViewController: UIViewController {
    lazy var instructionView = self.view as? NewCodeQuizFullscreenInstructionView

    private var currentContent: String?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewCodeQuizFullscreenInstructionView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension NewCodeQuizFullscreenInstructionViewController: NewCodeQuizFullscreenSubmoduleProtocol {
    func configure(viewModel: NewCodeQuizFullscreenViewModel) {
        guard self.currentContent != viewModel.content else {
            return
        }

        self.currentContent = viewModel.content

        self.instructionView?.startLoading()
        self.instructionView?.configure(
            htmlString: viewModel.content,
            samples: viewModel.samples,
            limit: viewModel.limit
        )
    }
}

extension NewCodeQuizFullscreenInstructionViewController: NewCodeQuizFullscreenInstructionViewDelegate {
    func newCodeQuizFullscreenInstructionViewDidLoadContent(_ view: NewCodeQuizFullscreenInstructionView) {
        self.instructionView?.endLoading()
    }

    func newCodeQuizFullscreenInstructionView(
        _ view: NewCodeQuizFullscreenInstructionView,
        didRequestOpenURL url: URL
    ) {
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

    func newCodeQuizFullscreenInstructionView(
        _ view: NewCodeQuizFullscreenInstructionView,
        didRequestFullscreenImage url: URL
    ) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }
}
