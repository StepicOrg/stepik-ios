import SnapKit
import UIKit

protocol UnsupportedQuizViewDelegate: AnyObject {
    func unsupportedQuizViewDidClickOnActionButton(_ view: UnsupportedQuizView)
}

extension UnsupportedQuizView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let titleColor = UIColor.stepikAccent
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let actionButtonCornerRadius: CGFloat = 8
        let actionButtonBorderWidth: CGFloat = 8
        let actionButtonBorderColor = UIColor.stepikAccent
        let actionButtonBackgroundColor = UIColor.stepikAccent
        let actionButtonTitleColor = UIColor.white
        let actionButtonHeight: CGFloat = 44
    }
}

final class UnsupportedQuizView: UIView {
    weak var delegate: UnsupportedQuizViewDelegate?

    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("UnsupportedQuizTitle", comment: "")
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("UnsupportedQuizActionButtonTitle", comment: ""), for: .normal)
        button.setTitleColor(self.appearance.actionButtonTitleColor, for: .normal)
        button.backgroundColor = self.appearance.actionButtonBackgroundColor
        button.layer.cornerRadius = self.appearance.actionButtonCornerRadius
        button.layer.borderWidth = self.appearance.actionButtonBorderWidth
        button.layer.borderColor = self.appearance.actionButtonBorderColor.cgColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [SeparatorView(), self.titleLabelContainerView, self.actionButtonContainerView]
        )
        stackView.spacing = self.appearance.spacing
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleLabelContainerView = UIView()
    private lazy var actionButtonContainerView = UIView()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func actionButtonClicked() {
        self.delegate?.unsupportedQuizViewDidClickOnActionButton(self)
    }
}

extension UnsupportedQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.titleLabelContainerView.addSubview(self.titleLabel)
        self.actionButtonContainerView.addSubview(self.actionButton)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.actionButtonHeight)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
