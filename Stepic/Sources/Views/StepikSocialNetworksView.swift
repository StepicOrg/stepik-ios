import SnapKit
import UIKit

extension StepikSocialNetworksView {
    struct Appearance {
        let backgroundColor = UIColor.clear

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)

        let stackViewHeight: CGFloat = 44
        let stackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        let stackViewSpacing: CGFloat = 16

        let socialNetworkButtonBackgroundColor = UIColor.white
        let socialNetworkButtonCornerRadius: CGFloat = 6
        let socialNetworkButtonSize = CGSize(width: 44, height: 44)
    }
}

final class StepikSocialNetworksView: UIView {
    let appearance: Appearance

    private static let idBySocialNetwork: [StepikSocialNetwork: Int] = {
        .init(uniqueKeysWithValues: StepikSocialNetwork.allCases.enumerated().map { ($1, $0) })
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.text = NSLocalizedString("StepikSocialNetworksTitle", comment: "")
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var onSocialNetworkClick: ((StepikSocialNetwork) -> Void)?

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

    private func makeSocialNetworkView(for socialNetwork: StepikSocialNetwork) -> UIView {
        let button = UIButton(type: .custom)
        button.setImage(socialNetwork.icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = self.appearance.socialNetworkButtonBackgroundColor
        button.layer.cornerRadius = self.appearance.socialNetworkButtonCornerRadius
        button.addTarget(self, action: #selector(self.socialNetworkClicked(sender:)), for: .touchUpInside)

        if let id = Self.idBySocialNetwork[socialNetwork] {
            button.tag = id
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.socialNetworkButtonSize)
        }

        return button
    }

    @objc
    private func socialNetworkClicked(sender: UIButton) {
        if let clickedSocialNetwork = Self.idBySocialNetwork.first(where: { $1 == sender.tag })?.key {
            self.onSocialNetworkClick?(clickedSocialNetwork)
        }
    }
}

extension StepikSocialNetworksView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.stackView)
        StepikSocialNetwork.allCases.forEach { self.stackView.addArrangedSubview(self.makeSocialNetworkView(for: $0)) }
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.stackViewHeight)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.stackViewInsets.top)
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.stackViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.stackViewInsets.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.stackViewInsets.right)
        }
    }
}
