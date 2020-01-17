import SnapKit
import UIKit

extension StepikSocialNetworksView {
    struct Appearance {
        let backgroundColor = UIColor.clear
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)

        let stackViewHeight: CGFloat = 44
        let stackViewInsets = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        let stackViewSpacing: CGFloat = 32
    }
}

final class StepikSocialNetworksView: UIView {
    let appearance: Appearance

    private static let socialNetworkByID: [StepikSocialNetwork: Int] = {
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
        stackView.distribution = .fillEqually
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var contentView = UIView()

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
        button.addTarget(self, action: #selector(self.socialNetworkClicked(sender:)), for: .touchUpInside)

        if let id = Self.socialNetworkByID[socialNetwork] {
            button.tag = id
        }

        return button
    }

    @objc
    private func socialNetworkClicked(sender: UIButton) {
        if let clickedSocialNetwork = Self.socialNetworkByID.first(where: { $1 == sender.tag })?.key {
            self.onSocialNetworkClick?(clickedSocialNetwork)
        }
    }
}

extension StepikSocialNetworksView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.stackView)
        StepikSocialNetwork.allCases.forEach { self.stackView.addArrangedSubview(self.makeSocialNetworkView(for: $0)) }
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.insets)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.stackViewHeight)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.stackViewInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.stackViewInsets)
        }
    }
}
