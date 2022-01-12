import SnapKit
import UIKit

extension CourseInfoTabNewsStatisticsView {
    struct Appearance {
        let stackViewInsets = LayoutInsets.default
        let stackViewSpacing: CGFloat = 4

        let titleFont = UIFont.systemFont(ofSize: 15)
        let titleTextColor = UIColor.stepikMaterialPrimaryText

        let countTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let countTitleTextColor = UIColor.stepikMaterialPrimaryText

        let backgroundColor = UIColor.stepikOverlayOnSurfaceBackground
        let cornerRadius: CGFloat = 8
    }
}

final class CourseInfoTabNewsStatisticsView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.stackViewInsets.top
                + stackViewIntrinsicContentSize.height
                + self.appearance.stackViewInsets.bottom
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

    func configure(viewModel: CourseInfoTabNewsStatisticsViewModel) {
        self.stackView.removeAllArrangedSubviews()

        let data = [
            (NSLocalizedString("CourseInfoTabNewsPublishCountTitle", comment: ""), viewModel.publishCount),
            (NSLocalizedString("CourseInfoTabNewsQueueCountTitle", comment: ""), viewModel.queueCount),
            (NSLocalizedString("CourseInfoTabNewsSentCountTitle", comment: ""), viewModel.sentCount),
            (NSLocalizedString("CourseInfoTabNewsOpenCountTitle", comment: ""), viewModel.openCount),
            (NSLocalizedString("CourseInfoTabNewsClickCountTitle", comment: ""), viewModel.clickCount)
        ]

        data.forEach { title, count in
            let label = self.makeLabel(title: title, count: count)
            self.stackView.addArrangedSubview(label)
        }

        self.invalidateIntrinsicContentSize()
    }

    private func makeLabel(title: String, count: Int) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left

        let countStringValue = "\(count)"
        let formattedTitle = "\(title): \(countStringValue)"

        let attributedTitle = NSMutableAttributedString(
            string: formattedTitle,
            attributes: [
                .font: self.appearance.titleFont,
                .foregroundColor: self.appearance.titleTextColor
            ]
        )

        if let countLocation = formattedTitle.indexOf(countStringValue) {
            attributedTitle.addAttributes(
                [
                    .font: self.appearance.countTitleFont,
                    .foregroundColor: self.appearance.countTitleTextColor,
                    .baselineOffset: -0.75
                ],
                range: NSRange(location: countLocation, length: countStringValue.count)
            )
        }

        label.attributedText = attributedTitle

        return label
    }
}

extension CourseInfoTabNewsStatisticsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.roundAllCorners(radius: self.appearance.cornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }
    }
}
