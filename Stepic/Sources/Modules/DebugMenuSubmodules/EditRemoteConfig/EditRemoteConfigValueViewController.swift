import SnapKit
import UIKit

final class EditRemoteConfigValueAssembly: Assembly {
    private let key: RemoteConfig.Key
    private let value: Any?

    weak var delegate: EditRemoteConfigValueViewControllerDelegate?

    init(key: RemoteConfig.Key, value: Any?, delegate: EditRemoteConfigValueViewControllerDelegate? = nil) {
        self.key = key
        self.value = value
        self.delegate = delegate
    }

    func makeModule() -> UIViewController {
        let viewController = EditRemoteConfigValueViewController(key: self.key, value: self.value)
        viewController.delegate = self.delegate
        return viewController
    }
}

// MARK: - EditRemoteConfigValueViewControllerDelegate -

protocol EditRemoteConfigValueViewControllerDelegate: AnyObject {
    func editRemoteConfigValueViewController(
        _ viewController: EditRemoteConfigValueViewController,
        didChangeValue value: Any?,
        forKey key: RemoteConfig.Key
    )
}

// MARK: - EditRemoteConfigValueViewController -

extension EditRemoteConfigValueViewController {
    struct Appearance {
        let titleLabelFont = Typography.headlineFont
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText

        let buttonFont = Typography.bodyFont
        let deleteButtonTintColor = UIColor.stepikRedFixed

        let textViewTextInsets = LayoutInsets.default
        let textViewFont = Typography.bodyFont
        let textViewTextColor = UIColor.stepikMaterialPrimaryText
        let textViewBorderCornerRadius: CGFloat = 8
        let textViewBorderWidth: CGFloat = 1
        let textViewBorderColor = UIColor.stepikSeparator
        let textViewHeight: CGFloat = 176

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets.default

        let backgroundColor = UIColor.stepikBackground
    }
}

final class EditRemoteConfigValueViewController: UIViewController {
    weak var delegate: EditRemoteConfigValueViewControllerDelegate?

    private let key: RemoteConfig.Key
    private let value: Any?

    private let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.key.rawValue
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.buttonFont
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(self.saveButtonClicked), for: .touchUpInside)
        button.setTitle("Save Debug Value", for: .normal)
        button.isEnabled = false
        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.deleteButtonTintColor
        button.titleLabel?.font = self.appearance.buttonFont
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(self.deleteButtonClicked), for: .touchUpInside)
        button.setTitle("Delete Debug Value", for: .normal)
        return button
    }()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.textViewFont
        textView.textColor = self.appearance.textViewTextColor
        textView.textInsets = self.appearance.textViewTextInsets.edgeInsets
        textView.setRoundedCorners(
            cornerRadius: self.appearance.textViewBorderCornerRadius,
            borderWidth: self.appearance.textViewBorderWidth,
            borderColor: self.appearance.textViewBorderColor
        )
        // Enable scrolling
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        // Disable features
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.dataDetectorTypes = []

        textView.delegate = self

        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    init(key: RemoteConfig.Key, value: Any?, appearance: Appearance = Appearance()) {
        self.key = key
        self.value = value
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Value"
        self.view.backgroundColor = self.appearance.backgroundColor
        self.stackView.backgroundColor = self.appearance.backgroundColor

        self.view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.saveButton)
        self.stackView.addArrangedSubview(self.deleteButton)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.leading.trailing
                .equalTo(self.view.safeAreaLayoutGuide)
                .inset(self.appearance.stackViewInsets.edgeInsets)
            make.bottom
                .lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.bottom)
                .offset(-self.appearance.stackViewInsets.bottom)
        }

        switch self.key.valueDataType {
        case .string:
            self.stackView.addArrangedSubview(self.textView)
            self.textView.translatesAutoresizingMaskIntoConstraints = false
            self.textView.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.textViewHeight)
            }

            self.textView.text = self.value as? String
        default:
            fatalError("\(self.key.valueDataType) not supported")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    // MARK: Private API

    @objc
    private func saveButtonClicked() {
        guard self.key.valueDataType == .string else {
            return
        }

        let textViewText = self.textView.text
        self.delegate?.editRemoteConfigValueViewController(self, didChangeValue: textViewText, forKey: self.key)
    }

    @objc
    private func deleteButtonClicked() {
        self.delegate?.editRemoteConfigValueViewController(self, didChangeValue: nil, forKey: self.key)
    }
}

// MARK: - EditRemoteConfigValueViewController: UITextViewDelegate -

extension EditRemoteConfigValueViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.saveButton.isEnabled = textView.text != (self.value as? String)
    }
}
