import SnapKit
import UIKit

protocol ExploreBlockHeaderViewProtocol: AnyObject {
    var onShowAllButtonClick: (() -> Void)? { get set }
    var titleText: String? { get set }
    var summaryText: String? { get set }
}

extension ExploreBlockHeaderView {
    struct Appearance {
        var titleLabelColor = UIColor.stepikSystemPrimaryText
        let titleLabelFont = Typography.title3Font
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        let descriptionLabelFont = Typography.calloutFont
        let descriptionLabelColor = UIColor.stepikSystemSecondaryText

        var showAllButtonColor = UIColor.stepikSystemSecondaryText
        let showAllButtonFont = Typography.title3Font
        let showAllButtonInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
}

final class ExploreBlockHeaderView: UIView, ExploreBlockHeaderViewProtocol {
    let appearance: Appearance

    private let analytics: Analytics

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelColor
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = self.appearance.titleLabelInsets.bottom
        return stackView
    }()

    var titleText: String? {
        didSet {
            self.titleLabel.isHidden = self.titleText == nil
            self.titleLabel.text = self.titleText
        }
    }

    var summaryText: String? {
        didSet {
            self.descriptionLabel.isHidden = self.summaryText == nil
            self.descriptionLabel.text = self.summaryText
        }
    }

    var shouldShowAllButton: Bool = true {
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

    // MARK: Button selector

    @objc
    private func showAllButtonClicked() {
        self.analytics.send(.courseListShowAllTapped)
        self.onShowAllButtonClick?()
    }
}

extension ExploreBlockHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.labelsStackView)
        self.labelsStackView.addArrangedSubview(self.titleLabel)
        self.labelsStackView.addArrangedSubview(self.descriptionLabel)

        self.addSubview(self.showAllButton)
    }

    func makeConstraints() {
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }

        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.showAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.leading
                .equalTo(self.labelsStackView.snp.trailing)
                .offset(self.appearance.showAllButtonInsets.left)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
    }
}
