import Nuke
import SnapKit
import UIKit

extension CourseInfoTabSyllabusCellStatsView {
    struct Appearance {
        let itemsSpacing: CGFloat = 8.0

        let itemTextFont = Typography.caption1Font
        let itemTextColor = UIColor.stepikMaterialSecondaryText

        let learnersImageColor = UIColor.stepikMaterialSecondaryText
        let learnersImageSize = CGSize(width: 8.5, height: 11)
        let learnersSpacing: CGFloat = 5.0

        let likesImageColor = UIColor.stepikMaterialSecondaryText
        let likesImageSize = CGSize(width: 10, height: 8.7)
        let likesSpacing: CGFloat = 5.0
    }
}

final class CourseInfoTabSyllabusCellStatsView: UIView {
    let appearance: Appearance

    private lazy var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.itemsSpacing
        return stackView
    }()

    private lazy var learnersView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.iconSpacing = self.appearance.learnersSpacing
        appearance.imageViewSize = self.appearance.learnersImageSize
        appearance.imageTintColor = self.appearance.learnersImageColor
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-user")?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var likesView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.iconSpacing = self.appearance.likesSpacing
        appearance.imageViewSize = self.appearance.likesImageSize
        appearance.imageTintColor = self.appearance.likesImageColor
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-info-lesson-like")?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var progressView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        // There is no icon in this view now
        appearance.iconSpacing = 0
        appearance.imageViewSize = .zero
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        return view
    }()

    private lazy var timeToCompleteView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        // There is no icon in this view now
        appearance.iconSpacing = 0
        appearance.imageViewSize = .zero
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        return view
    }()

    var learnersLabelText: String? {
        didSet {
            self.learnersView.isHidden = self.learnersLabelText?.isEmpty ?? true
            self.learnersView.text = self.learnersLabelText
        }
    }

    var likesCount: Int? {
        didSet {
            self.likesView.isHidden = self.likesCount == nil

            if let likesCount = self.likesCount {
                self.likesView.image = likesCount >= 0
                    ? UIImage(named: "course-info-lesson-like")?.withRenderingMode(.alwaysTemplate)
                    : UIImage(named: "course-info-lesson-dislike")?.withRenderingMode(.alwaysTemplate)
                self.likesView.text = "\(abs(likesCount))"
            }
        }
    }

    var progressLabelText: String? {
        didSet {
            self.progressView.isHidden = self.progressLabelText == nil
            self.progressView.text = self.progressLabelText
        }
    }

    var timeToCompleteLabelText: String? {
        didSet {
            self.timeToCompleteView.isHidden = self.timeToCompleteLabelText?.isEmpty ?? true
            self.timeToCompleteView.text = self.timeToCompleteLabelText
        }
    }

    var isEmpty: Bool {
        self.learnersView.isHidden
            && self.likesView.isHidden
            && self.progressView.isHidden
            && self.timeToCompleteView.isHidden
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.itemsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoTabSyllabusCellStatsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.likesView.isHidden = false
        self.progressView.isHidden = false
    }

    func addSubviews() {
        self.addSubview(self.itemsStackView)
        self.itemsStackView.addArrangedSubview(self.progressView)
        self.itemsStackView.addArrangedSubview(self.timeToCompleteView)
        self.itemsStackView.addArrangedSubview(self.learnersView)
        self.itemsStackView.addArrangedSubview(self.likesView)
    }

    func makeConstraints() {
        self.itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.itemsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
