import SnapKit
import UIKit

extension CertificateDetailVerticalTitleView {
    struct Appearance {
        let headlineLabelFont = Typography.caption1Font
        let headlineLabelTextColor = UIColor.stepikMaterialSecondaryText

        let bodyLabelFont = Typography.bodyFont
        let bodyLabelTextColor = UIColor.stepikMaterialPrimaryText
        let bodyLabelInsets = LayoutInsets(top: 8)
    }
}

final class CertificateDetailVerticalTitleView: UIControl {
    let appearance: Appearance

    private lazy var headlineLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.headlineLabelFont
        label.textColor = self.appearance.headlineLabelTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.bodyLabelFont
        label.textColor = self.appearance.bodyLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    var headlineText: String? {
        didSet {
            self.headlineLabel.text = self.headlineText
        }
    }

    var bodyText: String? {
        didSet {
            self.bodyLabel.text = self.bodyText
            self.invalidateIntrinsicContentSize()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.headlineLabel.intrinsicContentSize.height
            + self.appearance.bodyLabelInsets.top
            + self.bodyLabel.intrinsicContentSize.height
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

extension CertificateDetailVerticalTitleView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.headlineLabel)
        self.addSubview(self.bodyLabel)
    }

    func makeConstraints() {
        self.headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headlineLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.headlineLabel.snp.bottom).offset(self.appearance.bodyLabelInsets.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
