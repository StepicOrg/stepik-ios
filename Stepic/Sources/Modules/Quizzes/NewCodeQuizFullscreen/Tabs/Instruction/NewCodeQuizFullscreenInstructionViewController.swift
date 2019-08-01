import Agrume
import UIKit

final class NewCodeQuizFullscreenInstructionViewController: UIViewController {
    lazy var instructionView = self.view as? NewCodeQuizFullscreenInstructionView

    private let content: String
    private let samples: [NewCodeQuiz.CodeSample]
    private let limit: NewCodeQuiz.CodeLimit

    init(
        content: String,
        samples: [NewCodeQuiz.CodeSample],
        limit: NewCodeQuiz.CodeLimit
    ) {
        self.content = content
        self.samples = samples
        self.limit = limit
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instructionView?.startLoading()
        self.instructionView?.configure(htmlString: self.content, samples: self.samples, limit: self.limit)
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
