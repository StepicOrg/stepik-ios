import SnapKit
import UIKit

extension CourseBenefitDetailHeaderView {
    struct Appearance {
        let titleLabelFont = Typography.headlineFont
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let titleLabelInsets = LayoutInsets.default

        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor.stepikSeparator
        let separatorInsets = LayoutInsets(top: 16)

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CourseBenefitDetailHeaderView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.titleLabelInsets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.titleLabelInsets.bottom
                + self.appearance.separatorHeight
        )
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

extension CourseBenefitDetailHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.titleLabelInsets.edgeInsets)
            make.bottom.equalTo(self.separatorView.snp.top).offset(-self.appearance.titleLabelInsets.bottom)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
