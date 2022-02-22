import SnapKit
import UIKit

protocol CourseInfoViewDelegate: AnyObject {
    func courseInfoView(_ courseInfoView: CourseInfoView, didReportNewHeaderHeight height: CGFloat)
    func courseInfoView(_ courseInfoView: CourseInfoView, didRequestScrollToPage index: Int)
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int
    func courseInfoViewDidMainAction(_ courseInfoView: CourseInfoView)
    func courseInfoViewDidTryForFreeAction(_ courseInfoView: CourseInfoView)
    func courseInfoViewDidPlaceholderAction(_ view: CourseInfoView)
}

extension CourseInfoView {
    struct Appearance {
        // Status bar + navbar + other offsets
        var headerTopOffset: CGFloat = 0.0
        let segmentedControlHeight: CGFloat = 48.0

        let minimalHeaderHeight: CGFloat = 240

        let errorPlaceholderViewBackgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoView: UIView {
    let appearance: Appearance

    private let tabsTitles: [String]

    // Height values reported by header view
    private var calculatedHeaderHeight: CGFloat = 0

    private var currentPageIndex = 0

    private lazy var headerView: CourseInfoHeaderView = {
        let view = CourseInfoHeaderView()
        view.onActionButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.courseInfoViewDidMainAction(strongSelf)
        }
        view.onTryForFreeButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.courseInfoViewDidTryForFreeAction(strongSelf)
        }
        return view
    }()

    private lazy var segmentedControl: TabSegmentedControlView = {
        let control = TabSegmentedControlView(frame: .zero, items: self.tabsTitles)
        control.delegate = self
        return control
    }()

    private lazy var errorPlaceholderView: StepikPlaceholderView = {
        let appearance = StepikPlaceholderView.Appearance(
            backgroundColor: self.appearance.errorPlaceholderViewBackgroundColor
        )

        let view = StepikPlaceholderView()
        view.appearance = appearance
        view.delegate = self
        view.isHidden = true

        return view
    }()

    private let pageControllerView: UIView

    // Dynamic scrolling constraints
    private var topConstraint: Constraint?
    private var headerHeightConstraint: Constraint?

    /// Real height for header
    var headerHeight: CGFloat {
        max(0, self.calculatedHeaderHeight + self.appearance.headerTopOffset)
    }

    weak var delegate: CourseInfoViewDelegate?

    init(
        frame: CGRect = .zero,
        pageControllerView: UIView,
        scrollDelegate: UIScrollViewDelegate? = nil,
        tabsTitles: [String] = [],
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.pageControllerView = pageControllerView
        self.tabsTitles = tabsTitles
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.headerView)

        if self.headerView.bounds.contains(convertedPoint) {
            if let targetView = self.headerView.hitTest(convertedPoint, with: event) {
                return targetView
            }
        }

        return super.hitTest(point, with: event)
    }

    func setErrorPlaceholderVisible(_ isVisible: Bool) {
        if isVisible {
            self.errorPlaceholderView.set(placeholder: .noConnection)
            self.errorPlaceholderView.delegate = self
            self.errorPlaceholderView.isHidden = false
        } else {
            self.errorPlaceholderView.isHidden = true
        }
    }

    func setLoading(_ isLoading: Bool) {
        self.headerView.setLoading(isLoading)

        if isLoading {
            self.headerHeightConstraint?.update(offset: self.appearance.minimalHeaderHeight)
            self.delegate?.courseInfoView(
                self,
                didReportNewHeaderHeight: self.appearance.minimalHeaderHeight + self.appearance.segmentedControlHeight
            )
        } else {
            self.headerHeightConstraint?.update(offset: self.headerHeight)
        }
    }

    func configure(viewModel: CourseInfoHeaderViewModel) {
        // Update data in header
        self.headerView.configure(viewModel: viewModel)
        // Update header height
        self.calculatedHeaderHeight = self.headerView.intrinsicContentSize.height

        self.delegate?.courseInfoView(
            self,
            didReportNewHeaderHeight: self.headerHeight + self.appearance.segmentedControlHeight
        )
        self.headerHeightConstraint?.update(offset: self.headerHeight)
    }

    func updateScroll(offset: CGFloat) {
        // default position: offset == 0
        // overscroll (parallax effect): offset < 0
        // normal scrolling: offset > 0

        self.headerHeightConstraint?.update(offset: max(self.headerHeight, self.headerHeight + -offset))

        self.topConstraint?.update(offset: min(0, -offset))
    }

    func updateCurrentPageIndex(_ index: Int) {
        self.currentPageIndex = index
        self.segmentedControl.selectTab(index: index)
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
        self.backgroundColor = .stepikBackground
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.segmentedControl)
        self.insertSubview(self.pageControllerView, aboveSubview: self.headerView)
        self.addSubview(self.errorPlaceholderView)
    }

    func makeConstraints() {
        self.pageControllerView.translatesAutoresizingMaskIntoConstraints = false
        self.pageControllerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            self.topConstraint = make.top.equalToSuperview().constraint
            make.leading.trailing.equalToSuperview()
            self.headerHeightConstraint = make.height.equalTo(self.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(self.appearance.segmentedControlHeight)
        }

        self.errorPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        self.errorPlaceholderView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.centerX.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension CourseInfoView: TabSegmentedControlViewDelegate {
    func tabSegmentedControlView(_ tabSegmentedControlView: TabSegmentedControlView, didSelectTabWithIndex index: Int) {
        let tabsCount = self.delegate?.numberOfPages(in: self) ?? 0
        guard index >= 0, index < tabsCount else {
            return
        }

        self.delegate?.courseInfoView(self, didRequestScrollToPage: index)
        self.currentPageIndex = index
    }
}

extension CourseInfoView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.courseInfoViewDidPlaceholderAction(self)
    }
}
