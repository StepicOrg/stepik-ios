import Agrume
import UIKit

final class CodeQuizFullscreenInstructionViewController: UIViewController {
    lazy var instructionView = self.view as? CodeQuizFullscreenInstructionView

    private let content: String
    private let samples: [CodeSamplePlainObject]
    private let limit: CodeLimitPlainObject

    init(
        content: String,
        samples: [CodeSamplePlainObject],
        limit: CodeLimitPlainObject
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
        let view = CodeQuizFullscreenInstructionView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instructionView?.startLoading()
        self.instructionView?.configure(htmlString: self.content, samples: self.samples, limit: self.limit)
    }
}

extension CodeQuizFullscreenInstructionViewController: CodeQuizFullscreenInstructionViewDelegate {
    func codeQuizFullscreenInstructionViewDidLoadContent(_ view: CodeQuizFullscreenInstructionView) {
        self.instructionView?.endLoading()
    }

    func codeQuizFullscreenInstructionView(
        _ view: CodeQuizFullscreenInstructionView,
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

    func codeQuizFullscreenInstructionView(
        _ view: CodeQuizFullscreenInstructionView,
        didRequestFullscreenImage url: URL
    ) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }
}
