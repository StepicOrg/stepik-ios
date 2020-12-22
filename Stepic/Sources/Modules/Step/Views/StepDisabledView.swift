import SnapKit
import UIKit

extension StepDisabledView {
    struct Appearance {
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let titleTextColor = UIColor.stepikPrimaryText
        let titleInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let descriptionFont = Typography.bodyFont
        let descriptionTextColor = UIColor.stepikSecondaryText
        let descriptionInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)

        let backgroundColor = UIColor.stepikBackground
    }
}

final class StepDisabledView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 0
        label.text = NSLocalizedString("StepDisabledTitle", comment: "")
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 0
        label.text = NSLocalizedString("StepDisabledMessage", comment: "")
        return label
    }()

    override var intrinsicContentSize: CGSize {
        let height = self.titleLabel.intrinsicContentSize.height
            + self.appearance.descriptionInsets.top
            + self.descriptionLabel.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

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
}

extension StepDisabledView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.descriptionInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.descriptionInsets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.descriptionInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.descriptionInsets.right)
        }
    }
}
