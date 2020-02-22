import UIKit

protocol CodeQuizFullscreenRunCodeViewControllerProtocol: AnyObject {
    func displayContentUpdate(viewModel: CodeQuizFullscreenRunCode.ContentUpdate.ViewModel)
    func displayTestInputSetDefault(viewModel: CodeQuizFullscreenRunCode.TestInputSetDefault.ViewModel)
    func displayRunCodeResult(viewModel: CodeQuizFullscreenRunCode.RunCode.ViewModel)
    func displayTestInputSamples(viewModel: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.ViewModel)
    func displayAlert(viewModel: CodeQuizFullscreenRunCode.AlertPresentation.ViewModel)
}

final class CodeQuizFullscreenRunCodeViewController: UIViewController {
    private let interactor: CodeQuizFullscreenRunCodeInteractorProtocol

    lazy var runCodeView = self.view as? CodeQuizFullscreenRunCodeView

    private var lastSelectSampleActionSender: Any?

    init(interactor: CodeQuizFullscreenRunCodeInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CodeQuizFullscreenRunCodeView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

// MARK: - CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewControllerProtocol -

extension CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewControllerProtocol {
    func displayContentUpdate(viewModel: CodeQuizFullscreenRunCode.ContentUpdate.ViewModel) {
        self.runCodeView?.configure(viewModel: viewModel.viewModel)
    }

    func displayTestInputSetDefault(viewModel: CodeQuizFullscreenRunCode.TestInputSetDefault.ViewModel) {
        self.runCodeView?.testInput = viewModel.input
    }

    func displayRunCodeResult(viewModel: CodeQuizFullscreenRunCode.RunCode.ViewModel) {
        self.runCodeView?.configure(viewModel: viewModel.viewModel)
    }

    func displayTestInputSamples(viewModel: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        viewModel.samples.map { sample in
            UIAlertAction(
                title: sample,
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doTestInputTextUpdate(request: .init(input: sample))
                }
            )
        }.forEach { alert.addAction($0) }

        if let popoverPresentationController = alert.popoverPresentationController,
           let senderView = self.lastSelectSampleActionSender as? UIView {
            popoverPresentationController.sourceView = senderView
            popoverPresentationController.sourceRect = senderView.bounds
        }

        self.present(alert, animated: true, completion: nil)
    }

    func displayAlert(viewModel: CodeQuizFullscreenRunCode.AlertPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewDelegate-

extension CodeQuizFullscreenRunCodeViewController: CodeQuizFullscreenRunCodeViewDelegate {
    func codeQuizFullscreenRunCodeViewDidClickRunCode(_ view: CodeQuizFullscreenRunCodeView) {
        self.interactor.doRunCode(request: .init())
    }

    func codeQuizFullscreenRunCodeViewDidClickSamples(_ view: CodeQuizFullscreenRunCodeView, sender: Any) {
        self.lastSelectSampleActionSender = sender
        self.interactor.doTestInputSamplesPresentation(request: .init())
    }

    func codeQuizFullscreenRunCodeView(_ view: CodeQuizFullscreenRunCodeView, testInputDidChange input: String) {
        self.interactor.doTestInputTextUpdate(request: .init(input: input))
    }
}
