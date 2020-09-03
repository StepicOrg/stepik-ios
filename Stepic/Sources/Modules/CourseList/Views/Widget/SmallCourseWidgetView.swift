import SnapKit
import UIKit

extension SmallCourseWidgetView {
    struct Appearance {
        let coverViewInsets = LayoutInsets(top: 16, left: 16)
        let coverViewWidthHeight: CGFloat = 80.0

        let summaryLabelInsets = LayoutInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
}

final class SmallCourseWidgetView: UIView, CourseWidgetViewProtocol {
    let appearance: Appearance
    let colorMode: CourseListColorMode

    private lazy var coverView = CourseWidgetCoverView()

    private lazy var summaryLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetSummaryLabelAppearance
    )

    init(
        frame: CGRect = .zero,
        colorMode: CourseListColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.coverView.coverImageURL = viewModel.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel.isAdaptive

        self.summaryLabel.text = viewModel.summary
    }
}

extension SmallCourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        if self.colorMode == .grouped {
            self.backgroundColor = .stepikSecondaryGroupedBackground
        }
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.summaryLabel)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.left)
            make.height
                .width
                .equalTo(self.appearance.coverViewWidthHeight)
        }

        self.summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.summaryLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.summaryLabelInsets.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.summaryLabelInsets.left)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.bottom)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.right)
        }
    }
}
