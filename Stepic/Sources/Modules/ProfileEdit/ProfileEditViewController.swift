import UIKit

protocol ProfileEditViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: ProfileEdit.SomeAction.ViewModel)
}

final class ProfileEditViewController: UIViewController {
    private let interactor: ProfileEditInteractorProtocol

    lazy var profileEditView = self.view as? ProfileEditView

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
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = SettingsTableViewModel(
            sections: [
                .init(
                    header: .init(title: "Общие данные"),
                    cells: [
                        .init(
                            type: .input(
                                options: .init(shouldAlwaysShowPlaceholder: false, placeholderText: "", valueText: "")
                            ),
                            options: .init()
                        ),
                        .init(
                            type: .input(
                                options: .init(shouldAlwaysShowPlaceholder: false, placeholderText: "", valueText: "")
                            ),
                            options: .init()
                        )
                    ],
                    footer: .init(description: "Ваше официальное имя, используемое в сертификатах")
                ),
                .init(
                    header: .init(title: "О себе"),
                    cells: [],
                    footer: nil
                )
            ]
        )
        self.profileEditView?.update(viewModel: viewModel)
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func displaySomeActionResult(viewModel: ProfileEdit.SomeAction.ViewModel) { }
}