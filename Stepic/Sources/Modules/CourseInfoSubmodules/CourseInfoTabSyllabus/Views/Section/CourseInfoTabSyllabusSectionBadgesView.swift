import SnapKit
import UIKit

extension CourseInfoTabSyllabusSectionBadgesView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 8

        let cornerRadius: CGFloat = 10
        let widthDelta: CGFloat = 16
        let font = Typography.caption2Font

        let imageSize = CGSize(width: 12, height: 12)
        let imageInsets = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 0)
        let titleInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 8)
    }
}

final class CourseInfoTabSyllabusSectionBadgesView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var isEmpty: Bool { self.stackView.arrangedSubviews.isEmpty }

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

    func configure(viewModel: CourseInfoTabSyllabusSectionViewModel) {
        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
        }

        guard let examViewModel = viewModel.exam else {
            return
        }

        let typeBadge = self.makeBadgeView(
            image: nil,
            text: examViewModel.isProctored
                ? NSLocalizedString("ExamProctoredTitle", comment: "")
                : NSLocalizedString("ExamTitle", comment: ""),
            style: .violet
        )
        self.stackView.addArrangedSubview(typeBadge)

        switch examViewModel.state {
        case .canStart, .canNotStart:
            let durationBadge = self.makeBadgeView(
                image: UIImage(named: "course-info-syllabus-time")?.withRenderingMode(.alwaysTemplate),
                text: examViewModel.durationText,
                style: .green
            )
            self.stackView.addArrangedSubview(durationBadge)
        case .inProgress:
            let inProgressBadge = self.makeBadgeView(
                image: UIImage(named: "course-info-syllabus-in-progress"),
                text: NSLocalizedString("SyllabusExamInProgress", comment: ""),
                style: .violetWhite
            )
            self.stackView.addArrangedSubview(inProgressBadge)
        case .finished:
            let doneBadge = self.makeBadgeView(
                image: UIImage(named: "quiz-mark-correct")?.withRenderingMode(.alwaysTemplate),
                text: NSLocalizedString("SyllabusExamFinished", comment: ""),
                style: .greenWhite
            )
            self.stackView.addArrangedSubview(doneBadge)
        }
    }

    private func makeBadgeView(image: UIImage?, text: String, style: Style) -> UIView {
        if let image = image {
            let imageButton = ImageButton()
            imageButton.title = text
            imageButton.image = image
            imageButton.imageSize = self.appearance.imageSize
            imageButton.imageInsets = self.appearance.imageInsets
            imageButton.titleInsets = self.appearance.titleInsets
            imageButton.tintColor = style.tintColor
            imageButton.font = self.appearance.font
            imageButton.backgroundColor = style.backgroundColor
            imageButton.disabledAlpha = 1.0
            imageButton.isEnabled = false
            imageButton.layer.cornerRadius = self.appearance.cornerRadius
            imageButton.layer.masksToBounds = true
            imageButton.clipsToBounds = true
            return imageButton
        } else {
            let label = WiderLabel()
            label.text = text
            label.widthDelta = self.appearance.widthDelta
            label.font = self.appearance.font
            label.textColor = style.tintColor
            label.backgroundColor = style.backgroundColor
            label.textAlignment = .center
            label.numberOfLines = 1
            label.layer.cornerRadius = self.appearance.cornerRadius
            label.layer.masksToBounds = true
            label.clipsToBounds = true
            return label
        }
    }

    private enum Style {
        case violet
        case green
        case greenWhite
        case violetWhite

        var tintColor: UIColor {
            switch self {
            case .violet:
                return UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
            case .green:
                return .stepikGreen
            case .greenWhite:
                return .white
            case .violetWhite:
                return .white
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .violet:
                return .stepikOverlayViolet
            case .green:
                return UIColor.stepikGreen.withAlphaComponent(0.12)
            case .greenWhite:
                return .stepikGreenFixed
            case .violetWhite:
                return .stepikVioletFixed
            }
        }
    }
}

extension CourseInfoTabSyllabusSectionBadgesView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
