import Atributika
import SnapKit
import UIKit

extension StepTeacherDisabledView {
    struct Appearance {
        let feedbackViewInsets = LayoutInsets(inset: 16)

        let descriptionLabelFont = Typography.bodyFont
        let descriptionLabelTextColor = UIColor.stepikMaterialPrimaryText
        let descriptionLabelLinkColor = UIColor.stepikVioletFixed
        let descriptionLabelInsets = LayoutInsets(inset: 16)

        let separatorColor = UIColor.stepikSeparator
        let separatorHeight: CGFloat = 0.5

        let backgroundColor = UIColor.stepikBackground
    }
}

final class StepTeacherDisabledView: UIView {
    let appearance: Appearance

    private lazy var feedbackView = QuizFeedbackView()

    private lazy var descriptionLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelTextColor
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
        font: self.appearance.descriptionLabelFont,
        tagStyles: [
            Style("a")
                .foregroundColor(self.appearance.descriptionLabelLinkColor, .normal)
                .foregroundColor(self.appearance.descriptionLabelLinkColor.withAlphaComponent(0.5), .highlighted),
            Style("b").font(.boldSystemFont(ofSize: self.appearance.descriptionLabelFont.pointSize))
        ],
        tagTransformers: [.brTransformer]
    )

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var onLinkClick: ((URL) -> Void)?

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.feedbackViewInsets.top
            + self.feedbackView.intrinsicContentSize.height
            + self.appearance.descriptionLabelInsets.top
            + self.descriptionLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
            + self.appearance.descriptionLabelInsets.bottom
            + self.appearance.separatorHeight
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

    func configure(viewModel: DisabledStepViewModel) {
        self.feedbackView.update(state: .wrong, title: viewModel.disabled.title)
        self.feedbackView.setIconImage(UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate))

        self.descriptionLabel.attributedText = self.attributedTextConverter.convertToAttributedText(
            htmlString: viewModel.disabled.message
        )
    }
}

extension StepTeacherDisabledView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.feedbackView)
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.feedbackViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.feedbackViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.feedbackViewInsets.right)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.feedbackView.snp.bottom).offset(self.appearance.descriptionLabelInsets.top)
            make.leading.trailing.equalTo(self.feedbackView)
            make.bottom.equalTo(self.separatorView.snp.top).offset(-self.appearance.descriptionLabelInsets.bottom)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
