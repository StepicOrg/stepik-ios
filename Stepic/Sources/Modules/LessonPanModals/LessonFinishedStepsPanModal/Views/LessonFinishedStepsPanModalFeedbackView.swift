import SnapKit
import UIKit

extension LessonFinishedStepsPanModalFeedbackView {
    struct Appearance {
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let textColor = UIColor.stepikMaterialPrimaryText

        let cornerRadius: CGFloat = 13
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let backgroundColor = UIColor.dynamic(
            light: .stepikVioletFixed.withAlphaComponent(0.12),
            dark: .stepikSecondaryBackground
        )
    }
}

final class LessonFinishedStepsPanModalFeedbackView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.numberOfLines = 0
        return label
    }()

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.textLabel.intrinsicContentSize.height
                + self.appearance.insets.bottom
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

extension LessonFinishedStepsPanModalFeedbackView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.insets)
        }
    }
}
