import SnapKit
import UIKit

protocol ExploreCatalogBlockHeaderViewProtocol: ExploreBlockHeaderViewProtocol {
    var descriptionText: String? { get set }
}

extension ExploreCatalogBlockHeaderView {
    struct Appearance {
        var titleLabelColor = UIColor.stepikSystemPrimaryText
        let titleLabelFont = Typography.title3Font

        let subtitleLabelFont = Typography.calloutFont
        let subtitleLabelColor = UIColor.stepikSystemSecondaryText

        let descriptionLabelFont = Typography.calloutFont
        let descriptionLabelColor = UIColor.stepikSystemSecondaryText

        let labelsSpacing: CGFloat = 8

        var showAllButtonColor = UIColor.stepikSystemSecondaryText
        let showAllButtonFont = Typography.title3Font
        let showAllButtonInsets = LayoutInsets(left: 16)
    }
}

final class ExploreCatalogBlockHeaderView: UIView, ExploreCatalogBlockHeaderViewProtocol {
    let appearance: Appearance

    private let analytics: Analytics

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.showAllButtonColor
        button.titleLabel?.font = self.appearance.showAllButtonFont
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(self.showAllButtonClicked), for: .touchUpInside)
        button.setTitle(NSLocalizedString("ShowAll", comment: ""), for: .normal)
        return button
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.labelsSpacing
        return stackView
    }()

    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
            self.titleLabel.isHidden = self.titleText?.isEmpty ?? true
        }
    }

    // TODO: Refactor rename to subtitleText
    var summaryText: String? {
        didSet {
            self.subtitleLabel.text = self.summaryText
            self.subtitleLabel.isHidden = self.summaryText?.isEmpty ?? true
        }
    }

    var descriptionText: String? {
        didSet {
            self.descriptionLabel.text = self.descriptionText
            self.descriptionLabel.isHidden = self.descriptionText?.isEmpty ?? true
        }
    }

    var shouldShowAllButton = true {
        didSet {
            // We should not only hidden button but resize cause there is no space
            if self.shouldShowAllButton {
                self.showAllButton.isHidden = false
            } else {
                self.showAllButton.isHidden = true
                self.showAllButton.snp.makeConstraints { make in
                    make.width.equalTo(0)
                }
            }
        }
    }

    var onShowAllButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let labelsStackViewIntrinsicContentSize = self.labelsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: labelsStackViewIntrinsicContentSize.height
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.appearance = appearance
        self.analytics = analytics
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func showAllButtonClicked() {
        self.analytics.send(.courseListShowAllTapped)
        self.onShowAllButtonClick?()
    }
}

extension ExploreCatalogBlockHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.labelsStackView)
        self.labelsStackView.addArrangedSubview(self.titleLabel)
        self.labelsStackView.addArrangedSubview(self.subtitleLabel)
        self.labelsStackView.addArrangedSubview(self.descriptionLabel)

        self.addSubview(self.showAllButton)
    }

    func makeConstraints() {
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }

        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.showAllButton.snp.makeConstraints { make in
            make.leading
                .equalTo(self.labelsStackView.snp.trailing)
                .offset(self.appearance.showAllButtonInsets.left)
            make.right.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
    }
}
