import SnapKit
import UIKit

extension CourseInfoPurchaseModalHeaderView {
    struct Appearance {
        let titleFont = Typography.headlineFont
        let titleTextColor = UIColor.stepikMaterialPrimaryText

        let closeButtonFont = Typography.bodyFont
        let closeButtonTextColor = UIColor.stepikVioletFixed

        let titleLabelInsets = LayoutInsets(vertical: 16)
        let closeButtonInsets = LayoutInsets(right: 16)
    }
}

final class CourseInfoPurchaseModalHeaderView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("CourseInfoPurchaseModalTitle", comment: "")
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        button.titleLabel?.font = self.appearance.closeButtonFont
        button.setTitleColor(self.appearance.closeButtonTextColor, for: .normal)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var separatorView = SeparatorView()

    var onCloseClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.titleLabelInsets.top
            + self.titleLabel.intrinsicContentSize.height
            + self.appearance.titleLabelInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func closeButtonClicked() {
        self.onCloseClick?()
    }
}

extension CourseInfoPurchaseModalHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.closeButton)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
        }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.closeButtonInsets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
