import SVProgressHUD
import UIKit
import IQKeyboardManagerSwift

protocol ProfileEditViewControllerProtocol: class {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel)
    func displayProfileEditResult(viewModel: ProfileEdit.RemoteProfileUpdate.ViewModel)
}

final class ProfileEditViewController: UIViewController {
    private let interactor: ProfileEditInteractorProtocol

    lazy var profileEditView = self.view as? ProfileEditView

    private lazy var cancelBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(self.cancelButtonDidClick)
        )
        return button
    }()

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
        self.title = "Редактирование"

        self.interactor.doProfileEditLoad(request: .init())

        // Cause IQKeyboardManager is buggy
        IQKeyboardManager.sharedManager().enable = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    private func updateSaveButtonState() {
        guard let state = self.formState else {
            return
        }

        // Validate state here
        let isFirstNameValid = !state.firstName.isEmpty
        let isLastNameValid = !state.lastName.isEmpty

        let isFormValid = isFirstNameValid && isLastNameValid
        self.profileEditView?.isSaveButtonEnabled = isFormValid
    }

    private enum FormField: String {
        case firstName
        case lastName

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
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel) {
        let profileEditViewModel = viewModel.viewModel
        let state = FormState(firstName: profileEditViewModel.firstName, lastName: profileEditViewModel.lastName)

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
                            uniqueIdentifier: "",
                            type: .largeInput(
                                options: .init(
                                    placeholderText: "Краткая биография (до 255 символов)",
                                    valueText: "text",
                                    maxLength: 255
                                )
                            ),
                            options: .init()
                        ),
                        .init(
                            uniqueIdentifier: "",
                            type: .largeInput(
                                options: .init(
                                    placeholderText: "Обо мне",
                                    valueText: "text",
                                    maxLength: 255
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
    // MARK: ProfileEditViewDelegate

    func profileEditViewDidReportSaveButtonClick(_ profileEditView: ProfileEditView) {
        guard let state = self.formState else {
            return
        }

        let request = ProfileEdit.RemoteProfileUpdate.Request(
            firstName: state.firstName,
            lastName: state.lastName
        )

        // Show HUD here, hide in displayProfileEditResult(viewModel:)
        SVProgressHUD.show()
        self.interactor.doRemoteProfileUpdate(request: request)
    }

    // MARK: SettingsTableViewDelegate

    func settingsCell(
        elementView: UITextField,
        didReportTextChange text: String?,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {
        guard let id = uniqueIdentifier, let field = FormField(uniqueIdentifier: id) else {
            return
        }

        switch field {
        case .firstName:
            self.formState?.firstName = text ?? ""
        case .lastName:
            self.formState?.lastName = text ?? ""
        }

        self.updateSaveButtonState()
    }
}
