import SVProgressHUD
import UIKit

protocol CertificateDetailViewControllerProtocol: AnyObject {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel)
    func displayCertificateShare(viewModel: CertificateDetail.CertificateSharePresentation.ViewModel)
    func displayCertificatePDF(viewModel: CertificateDetail.CertificatePDFPresentation.ViewModel)
    func displayCourse(viewModel: CertificateDetail.CoursePresentation.ViewModel)
    func displayRecipient(viewModel: CertificateDetail.RecipientPresentation.ViewModel)
    func displayPromptForChangeCertificateNameInput(
        viewModel: CertificateDetail.PromptForChangeCertificateNameInput.ViewModel
    )
    func displayUpdateCertificateRecipientNameResult(
        viewModel: CertificateDetail.UpdateCertificateRecipientName.ViewModel
    )
}

final class CertificateDetailViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CertificateDetailInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var certificateDetailView: CertificateDetailView? { self.view as? CertificateDetailView }

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(self.shareButtonClicked)
        )
        item.isEnabled = false
        return item
    }()

    private weak var changeCertificateNameTextField: UITextField?
    private weak var changeCertificateNameOKAction: UIAlertAction?

    private var state: CertificateDetail.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    init(
        interactor: CertificateDetailInteractorProtocol,
        initialState: CertificateDetail.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CertificateDetailView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.state = .loading
                    strongSelf.interactor.doCertificateLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState()
        self.interactor.doCertificateLoad(request: .init())
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.shareBarButtonItem.isEnabled = true
            self.certificateDetailView?.hideLoading()

            self.title = viewModel.isWithDistinction
                ? NSLocalizedString("CertificateDetailWithDistinctionTitle", comment: "")
                : NSLocalizedString("CertificateDetailTitle", comment: "")

            self.certificateDetailView?.configure(viewModel: viewModel)
        case .loading:
            self.isPlaceholderShown = false
            self.shareBarButtonItem.isEnabled = false
            self.certificateDetailView?.showLoading()
        case .error:
            self.shareBarButtonItem.isEnabled = false
            self.certificateDetailView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        }
    }

    @objc
    private func shareButtonClicked() {
        self.interactor.doCertificateSharePresentation(request: .init())
    }
}

// MARK: - CertificateDetailViewController: CertificateDetailViewControllerProtocol -

extension CertificateDetailViewController: CertificateDetailViewControllerProtocol {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayCertificateShare(viewModel: CertificateDetail.CertificateSharePresentation.ViewModel) {
        DispatchQueue.global().async {
            let sharingViewController = SharingHelper.getSharingController(viewModel.url.absoluteString)
            DispatchQueue.main.async {
                sharingViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
                self.present(sharingViewController, animated: true)
            }
        }
    }

    func displayCertificatePDF(viewModel: CertificateDetail.CertificatePDFPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .certificate,
            allowsSafari: true,
            backButtonStyle: .close
        )
    }

    func displayCourse(viewModel: CertificateDetail.CoursePresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            courseViewSource: .certificate(id: viewModel.certificateID)
        )
        self.push(module: assembly.makeModule())
    }

    func displayRecipient(viewModel: CertificateDetail.RecipientPresentation.ViewModel) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func displayPromptForChangeCertificateNameInput(
        viewModel: CertificateDetail.PromptForChangeCertificateNameInput.ViewModel
    ) {
        self.promptForChangeCertificateNameInput(
            editsCount: viewModel.editsCount,
            allowedEditsCount: viewModel.allowedEditsCount,
            savedFullName: viewModel.savedFullName,
            predefinedNewFullName: viewModel.predefinedNewFullName
        )
    }

    func displayUpdateCertificateRecipientNameResult(
        viewModel: CertificateDetail.UpdateCertificateRecipientName.ViewModel
    ) {
        switch viewModel.state {
        case .failure(let predefinedNewFullName):
            SVProgressHUD.showError(
                withStatus: NSLocalizedString("CertificateNameChangeErrorStatusMessage", comment: "")
            )
            self.interactor.doPromptForChangeCertificateNameInput(
                request: .init(predefinedNewFullName: predefinedNewFullName)
            )
        case .success(let viewModel):
            SVProgressHUD.showSuccess(
                withStatus: NSLocalizedString("CertificateNameChangeSuccessStatusMessage", comment: "")
            )
            self.state = .result(data: viewModel)
        }
    }
}

// MARK: - CertificateDetailViewController: CertificateDetailViewDelegate -

extension CertificateDetailViewController: CertificateDetailViewDelegate {
    func certificateDetailViewDidClickPreview(_ view: CertificateDetailView) {
        self.interactor.doCertificatePDFPresentation(request: .init())
    }

    func certificateDetailViewDidClickCourse(_ view: CertificateDetailView) {
        self.interactor.doCoursePresentation(request: .init())
    }

    func certificateDetailViewDidClickRecipient(_ view: CertificateDetailView) {
        self.interactor.doRecipientPresentation(request: .init())
    }

    func certificateDetailViewDidClickEdit(_ view: CertificateDetailView) {
        self.interactor.doPromptForChangeCertificateNameInput(request: .init())
    }
}

// MARK: - CertificateDetailViewController (Certificate Change Name) -

extension CertificateDetailViewController {
    private func promptForChangeCertificateNameInput(
        editsCount: Int,
        allowedEditsCount: Int,
        savedFullName: String,
        predefinedNewFullName: String? = nil
    ) {
        let message = String(
            format: NSLocalizedString("CertificateNameChangeAlertMessageWarning", comment: ""),
            arguments: [FormatterHelper.timesCount(allowedEditsCount)]
        )

        let alert = UIAlertController(
            title: NSLocalizedString("CertificateNameChangeAlertTitle", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addTextField()
        self.changeCertificateNameTextField = alert.textFields?.first
        self.changeCertificateNameTextField?.placeholder = NSLocalizedString(
            "CertificateNameChangeAlertTextFieldPlaceholder",
            comment: ""
        )
        self.changeCertificateNameTextField?.delegate = self
        if let predefinedNewFullName = predefinedNewFullName {
            self.changeCertificateNameTextField?.text = predefinedNewFullName
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        let okAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: { [weak self, weak alert] _ in
                guard let strongSelf = self,
                      let strongAlert = alert else {
                    return
                }

                guard let text = strongAlert.textFields?.first?.text?.trimmed(),
                      !text.isEmpty else {
                    return SVProgressHUD.showError(
                        withStatus: NSLocalizedString("CertificateNameChangeEmptyTextFieldErrorMessage", comment: "")
                    )
                }

                strongSelf.promptForChangeCertificateName(
                    editsCount: editsCount,
                    allowedEditsCount: allowedEditsCount,
                    savedFullName: savedFullName,
                    newFullName: text
                )
            }
        )
        okAction.isEnabled = !(predefinedNewFullName ?? "").trimmed().isEmpty
        alert.addAction(okAction)
        self.changeCertificateNameOKAction = okAction

        self.present(alert, animated: true)
    }

    private func promptForChangeCertificateName(
        editsCount: Int,
        allowedEditsCount: Int,
        savedFullName: String,
        newFullName: String
    ) {
        var message = String(
            format: NSLocalizedString("CertificateNameChangeAlertMessageConfirmation", comment: ""),
            arguments: [savedFullName, newFullName]
        )

        let isLastEdit = (editsCount + 1) == allowedEditsCount
        if isLastEdit {
            message += "\n\(NSLocalizedString("CertificateNameChangeAlertMessageLastEditWarning", comment: ""))"
        }

        let alert = UIAlertController(
            title: NSLocalizedString("CertificateNameChangeAlertTitle", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    SVProgressHUD.show()
                    strongSelf.interactor.doUpdateCertificateRecipientName(request: .init(newFullName: newFullName))
                }
            )
        )

        self.present(alert, animated: true)
    }
}

// MARK: - CertificateDetailViewController: UITextFieldDelegate -

extension CertificateDetailViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard self.changeCertificateNameTextField === textField else {
            return true
        }

        let stringFromTextField = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""

        self.changeCertificateNameOKAction?.isEnabled = !stringFromTextField.trimmed().isEmpty

        return true
    }
}
