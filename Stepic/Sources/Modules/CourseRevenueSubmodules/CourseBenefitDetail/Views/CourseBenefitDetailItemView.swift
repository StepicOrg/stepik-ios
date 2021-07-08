import SnapKit
import UIKit

extension CourseBenefitDetailItemView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 15)
        let titleLabelLargeFont = Typography.bodyFont
        let titleLabelTextColor = UIColor.stepikMaterialSecondaryText
        let titleLabelInsets = LayoutInsets.default

        let rightDetailLabelFont = UIFont.systemFont(ofSize: 15)
        let rightDetailLabelLargeFont = Typography.headlineFont
        let rightDetailLabelTextColor = UIColor.stepikMaterialPrimaryText
        let rightDetailLabelClickableTextColor = UIColor.stepikVioletFixed
        let rightDetailLabelInsets = LayoutInsets.default
    }
}

final class CourseBenefitDetailItemView: UIView {
    let appearance: Appearance

    private let isClickable: Bool
    private let isLargeTitles: Bool

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.isLargeTitles
            ? self.appearance.titleLabelLargeFont
            : self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var rightDetailLabel: UILabel = {
        let label = UILabel()
        label.font = self.isLargeTitles
            ? self.appearance.rightDetailLabelLargeFont
            : self.appearance.rightDetailLabelFont
        label.textColor = self.isClickable
            ? self.appearance.rightDetailLabelClickableTextColor
            : self.appearance.rightDetailLabelTextColor
        label.textAlignment = .left
        label.numberOfLines = 0

        if self.isClickable {
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(self.rightDetailLabelTapped)
            )
            tapGestureRecognizer.numberOfTapsRequired = 1
            label.addGestureRecognizer(tapGestureRecognizer)
            label.isUserInteractionEnabled = true
        }

        return label
    }()

    private var titleLabelWidthConstraint: Constraint?
    private var rightDetailLabelLeadingConstraint: Constraint?

    var titleLabelIntrinsicContentWidth: CGFloat {
        self.titleLabel.intrinsicContentSize.width
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var detailTitle: String? {
        didSet {
            self.rightDetailLabel.text = self.detailTitle
        }
    }

    var onRightDetailLabelTapped: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let topInset = max(self.appearance.titleLabelInsets.top, self.appearance.rightDetailLabelInsets.top)
        let contentHeight = max(
            self.titleLabel.intrinsicContentSize.height,
            self.rightDetailLabel.intrinsicContentSize.height
        )
        let bottomInset = max(self.appearance.titleLabelInsets.bottom, self.appearance.rightDetailLabelInsets.bottom)

        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: topInset + contentHeight + bottomInset
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        isClickable: Bool = false,
        isLargeTitles: Bool = false
    ) {
        self.appearance = appearance
        self.isClickable = isClickable
        self.isLargeTitles = isLargeTitles

        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitleLabelWidth(_ width: CGFloat) {
        self.titleLabelWidthConstraint?.activate()
        self.titleLabelWidthConstraint?.update(offset: width)

        self.rightDetailLabelLeadingConstraint?.activate()

        self.invalidateIntrinsicContentSize()
    }

    @objc
    private func rightDetailLabelTapped() {
        self.onRightDetailLabelTapped?()
    }
}

extension CourseBenefitDetailItemView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.rightDetailLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(self.appearance.titleLabelInsets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleLabelInsets.bottom)

            self.titleLabelWidthConstraint = make.width.equalTo(0).constraint
            self.titleLabelWidthConstraint?.deactivate()
        }

        self.rightDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.rightDetailLabelInsets.top)

            self.rightDetailLabelLeadingConstraint = make.leading
                .equalTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.rightDetailLabelInsets.left)
                .constraint
            self.rightDetailLabelLeadingConstraint?.deactivate()

            make.bottom.equalToSuperview().offset(-self.appearance.rightDetailLabelInsets.bottom)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.rightDetailLabelInsets.right)
        }
    }
}
