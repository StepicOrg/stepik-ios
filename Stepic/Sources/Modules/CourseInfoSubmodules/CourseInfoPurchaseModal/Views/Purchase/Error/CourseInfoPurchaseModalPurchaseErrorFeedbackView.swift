import Atributika
import SnapKit
import UIKit

extension CourseInfoPurchaseModalPurchaseErrorFeedbackView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 20, height: 20)
        let iconImageViewInsets = LayoutInsets(horizontal: 16)
        let iconImageViewTintColor = UIColor.stepikDiscountPriceText

        let titleLabelFont = Typography.calloutFont
        let titleLabelTextColor = UIColor.stepikDiscountPriceText
        let titleLabelInsets = LayoutInsets.default

        let cornerRadius: CGFloat = 8
        let backgroundColor = UIColor.stepikDiscountPriceText.withAlphaComponent(0.12)
    }
}

final class CourseInfoPurchaseModalPurchaseErrorFeedbackView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(
            named: "CourseInfoPurchaseModalPurchaseFailExclamationMark"
        )?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageViewTintColor
        return imageView
    }()

    private lazy var titleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0
        label.onClick = { [weak self] _, detection in
            guard let strongSelf = self else {
                return
            }

            switch detection.type {
            case .tag(let tag):
                if tag.name == "a",
                   let href = tag.attributes["href"],
                   let url = URL(string: href) {
                    strongSelf.onLinkClick?(url)
                }
            default:
                break
            }
        }
        return label
    }()

    private lazy var attributedTextConverter = HTMLToAttributedStringConverter(
        font: self.appearance.titleLabelFont,
        tagStyles: [
            Style("a")
                .font(.boldSystemFont(ofSize: self.appearance.titleLabelFont.pointSize))
                .foregroundColor(self.appearance.titleLabelTextColor, .normal)
                .foregroundColor(self.appearance.titleLabelTextColor.withAlphaComponent(0.5), .highlighted)
        ],
        tagTransformers: [.brTransformer]
    )

    var onLinkClick: ((URL) -> Void)?

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.titleLabelInsets.top
            + self.titleLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
            + self.appearance.titleLabelInsets.bottom
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

        self.titleLabel.attributedText = self.attributedTextConverter.convertToAttributedText(
            htmlString: NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorFeedbackMessage", comment: "")
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoPurchaseModalPurchaseErrorFeedbackView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.clipsToBounds = true

        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconImageViewSize)
            make.leading.equalToSuperview().offset(self.appearance.iconImageViewInsets.left)
            make.centerY.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(self.appearance.titleLabelInsets.edgeInsets)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
        }
    }
}
