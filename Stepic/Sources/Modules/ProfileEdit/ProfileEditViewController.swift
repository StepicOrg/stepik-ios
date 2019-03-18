import UIKit

protocol ProfileEditViewControllerProtocol: class {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel)
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
    }

    @objc
    private func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    enum SettingsField: String {
        case firstName
        case lastName
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func displayProfileEditForm(viewModel: ProfileEdit.ProfileEditLoad.ViewModel) {
        let profileEditViewModel = viewModel.viewModel

        let viewModel = SettingsTableViewModel(
            sections: [
                .init(
                    header: .init(title: "Общие данные"),
                    cells: [
                        .init(
                            uniqueIdentifier: SettingsField.firstName.rawValue,
                            type: .input(
                                options: .init(
                                    shouldAlwaysShowPlaceholder: true,
                                    placeholderText: "Имя",
                                    valueText: profileEditViewModel.firstName
                                )
                            ),
                            options: .init()
                        ),
                        .init(
                            uniqueIdentifier: "lastname",
                            type: .input(
                                options: .init(
                                    shouldAlwaysShowPlaceholder: true,
                                    placeholderText: "Фамилия",
                                    valueText: profileEditViewModel.lastName
                                )
                            ),
                            options: .init()
                        )
                    ],
                    footer: .init(description: "Ваше официальное имя, используемое в сертификатах")
                )
            ]
        )
        self.profileEditView?.update(viewModel: viewModel)
    }
}

extension ProfileEditViewController: ProfileEditViewDelegate {
    // MARK: ProfileEditViewDelegate

    // MARK: SettingsTableViewDelegate

    func settingsCell(
        elementView: UITextField,
        didReportTextChange text: String?,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {

    }
}
