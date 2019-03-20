import SVProgressHUD
import UIKit

protocol ProfileEditViewControllerProtocol: class {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel)
    func displayProfileEditResult(viewModel: ProfileEdit.RemoteProfileUpdate.ViewModel)
}

final class ProfileEditViewController: UIViewController {
    private let interactor: ProfileEditInteractorProtocol

    lazy var profileEditView = self.view as? ProfileEditView

    private lazy var cancelBarButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(self.cancelButtonDidClick)
    )

    private lazy var doneBarButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(self.doneButtonDidClick)
    )

    private var formState: FormState?

    init(interactor: ProfileEditInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileEditView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.cancelBarButton
        self.navigationItem.rightBarButtonItem = self.doneBarButton
        self.title = "Редактирование"

        self.interactor.doProfileEditLoad(request: .init())
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func doneButtonDidClick(_ sender: UIBarButtonItem) {
        guard let state = self.formState else {
            return
        }

        let request = ProfileEdit.RemoteProfileUpdate.Request(
            firstName: state.firstName,
            lastName: state.lastName,
            shortBio: state.shortBio,
            details: state.details
        )

        // Show HUD here, hide in displayProfileEditResult(viewModel:)
        SVProgressHUD.show()
        self.interactor.doRemoteProfileUpdate(request: request)
    }

    private func updateSaveButtonState() {
        guard let state = self.formState else {
            return
        }

        // Validate state here
        let isFirstNameValid = !state.firstName.isEmpty
        let isLastNameValid = !state.lastName.isEmpty

        let isFormValid = isFirstNameValid && isLastNameValid
        self.doneBarButton.isEnabled = isFormValid
    }

    private func handleTextField(uniqueIdentifier: UniqueIdentifierType?, text: String?) {
        guard let id = uniqueIdentifier, let field = FormField(uniqueIdentifier: id) else {
            return
        }

        switch field {
        case .firstName:
            self.formState?.firstName = text ?? ""
        case .lastName:
            self.formState?.lastName = text ?? ""
        case .shortBio:
            self.formState?.shortBio = text ?? ""
        case .details:
            self.formState?.details = text ?? ""
        }

        self.updateSaveButtonState()
    }

    private enum FormField: String {
        case firstName
        case lastName
        case shortBio
        case details

        init?(uniqueIdentifier: UniqueIdentifierType) {
            if let value = FormField(rawValue: uniqueIdentifier) {
                self = value
            } else {
                return nil
            }
        }
    }

    private struct FormState {
        var firstName: String
        var lastName: String
        var shortBio: String
        var details: String
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel) {
        let profileEditViewModel = viewModel.viewModel
        let state = FormState(
            firstName: profileEditViewModel.firstName,
            lastName: profileEditViewModel.lastName,
            shortBio: profileEditViewModel.shortBio,
            details: profileEditViewModel.details
        )

        let viewModel = SettingsTableViewModel(
            sections: [
                .init(
                    header: .init(title: "Общие данные"),
                    cells: [
                        .init(
                            uniqueIdentifier: FormField.firstName.rawValue,
                            type: .input(
                                options: .init(
                                    shouldAlwaysShowPlaceholder: true,
                                    placeholderText: "Имя",
                                    valueText: state.firstName
                                )
                            ),
                            options: .init()
                        ),
                        .init(
                            uniqueIdentifier: FormField.lastName.rawValue,
                            type: .input(
                                options: .init(
                                    shouldAlwaysShowPlaceholder: true,
                                    placeholderText: "Фамилия",
                                    valueText: state.lastName
                                )
                            ),
                            options: .init()
                        )
                    ],
                    footer: .init(description: "Ваше официальное имя, используемое в сертификатах")
                ),
                .init(
                    header: .init(title: "О себе"),
                    cells: [
                        .init(
                            uniqueIdentifier: FormField.shortBio.rawValue,
                            type: .largeInput(
                                options: .init(
                                    placeholderText: "Краткая биография (до 255 символов)",
                                    valueText: state.shortBio,
                                    maxLength: 255
                                )
                            ),
                            options: .init()
                        ),
                        .init(
                            uniqueIdentifier: FormField.details.rawValue,
                            type: .largeInput(
                                options: .init(
                                    placeholderText: "Обо мне",
                                    valueText: state.details,
                                    maxLength: nil
                                )
                            ),
                            options: .init()
                        )
                    ],
                    footer: nil
                )
            ]
        )

        self.formState = state
        self.profileEditView?.update(viewModel: viewModel)

        self.updateSaveButtonState()
    }

    func displayProfileEditResult(viewModel: ProfileEdit.RemoteProfileUpdate.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.dismiss()
            self.dismiss(animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: nil)
        }
    }
}

extension ProfileEditViewController: ProfileEditViewDelegate {
    // MARK: SettingsTableViewDelegate

    func settingsCell(
        elementView: UITextField,
        didReportTextChange text: String?,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {
       self.handleTextField(uniqueIdentifier: uniqueIdentifier, text: text)
    }

    func settingsCell(
        elementView: UITextView,
        didReportTextChange text: String,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {
        self.handleTextField(uniqueIdentifier: uniqueIdentifier, text: text)
    }
}
