import SnapKit
import UIKit

protocol CourseRevenueViewDelegate: AnyObject {
    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didReportNewHeaderHeight height: CGFloat)
    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didClickSummary expanded: Bool)
    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didRequestScrollToPage index: Int)
    func numberOfPages(in courseRevenueView: CourseRevenueView) -> Int
}

extension CourseRevenueView {
    struct Appearance {
        // Status bar + navbar + other offsets
        var headerTopOffset: CGFloat = 0.0
        let segmentedControlHeight: CGFloat = 61

        let minimalHeaderHeight: CGFloat = 78

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CourseRevenueView: UIView {
    let appearance: Appearance

    private let tabsTitles: [String]

    // Height values reported by header view
    private var calculatedHeaderHeight: CGFloat = 0

    private var currentPageIndex = 0

    private lazy var headerView: CourseRevenueHeaderView = {
        let view = CourseRevenueHeaderView()
        view.onSummaryButtonClick = { [weak self] expanded in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseRevenueView(strongSelf, didClickSummary: expanded)
        }
        return view
    }()

    private lazy var segmentedControl: CourseRevenueTabSegmentedControlView = {
        let control = CourseRevenueTabSegmentedControlView(tabsTitles: self.tabsTitles)
        control.segmentedControlValueDidChange = self.onSegmentedControlValueChanged(_:)
        return control
    }()

    private let pageControllerView: UIView

    // Dynamic scrolling constraints
    private var topConstraint: Constraint?
    private var headerHeightConstraint: Constraint?

    /// Real height for header
    var headerHeight: CGFloat {
        max(
            0,
            max(self.appearance.minimalHeaderHeight, self.calculatedHeaderHeight) + self.appearance.headerTopOffset
        )
    }

    weak var delegate: CourseRevenueViewDelegate?

    private var isLoading = false

    init(
        frame: CGRect = .zero,
        pageControllerView: UIView,
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateHeaderHeight()
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

    func setLoading(_ isLoading: Bool) {
        let oldIsLoadingValue = self.isLoading
        self.isLoading = isLoading

        self.headerView.setLoading(isLoading)

        if isLoading {
            self.headerHeightConstraint?.update(offset: self.appearance.minimalHeaderHeight)
            self.delegate?.courseRevenueView(
                self,
                didReportNewHeaderHeight: self.appearance.minimalHeaderHeight
                    + self.appearance.headerTopOffset
                    + self.appearance.segmentedControlHeight
            )
        } else {
            self.updateHeaderHeight(forceUpdate: oldIsLoadingValue != isLoading)
        }
    }

    func configure(viewModel: CourseRevenueEmptyHeaderViewModel) {
        self.headerView.configure(viewModel: viewModel)
        self.updateHeaderHeight(forceUpdate: true)
    }

    func configure(viewModel: CourseRevenueHeaderViewModel) {
        self.headerView.configure(viewModel: viewModel)
        self.updateHeaderHeight(forceUpdate: true)
    }

    func updateScroll(offset: CGFloat) {
        self.topConstraint?.update(offset: -offset)

        if self.isLoading {
            self.segmentedControl.backgroundColor = self.appearance.backgroundColor
        } else {
            self.segmentedControl.backgroundColor = offset < (self.headerHeight - self.appearance.headerTopOffset * 2)
                ? .clear
                : self.appearance.backgroundColor
        }
    }

    func updateCurrentPageIndex(_ index: Int) {
        self.currentPageIndex = index
        self.segmentedControl.selectedSegmentIndex = index
    }

    private func onSegmentedControlValueChanged(_ selectedSegmentIndex: Int) {
        let tabsCount = self.delegate?.numberOfPages(in: self) ?? 0

        guard selectedSegmentIndex >= 0,
              selectedSegmentIndex < tabsCount else {
            self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
            return
        }

        self.delegate?.courseRevenueView(self, didRequestScrollToPage: selectedSegmentIndex)
        self.currentPageIndex = selectedSegmentIndex
    }

    private func updateHeaderHeight(forceUpdate: Bool = false) {
        let newHeaderHeight = self.headerView.intrinsicContentSize.height

        if self.calculatedHeaderHeight != newHeaderHeight || forceUpdate {
            self.calculatedHeaderHeight = newHeaderHeight

            self.delegate?.courseRevenueView(
                self,
                didReportNewHeaderHeight: self.headerHeight + self.appearance.segmentedControlHeight
            )

            self.headerHeightConstraint?.update(offset: self.calculatedHeaderHeight)
        }
    }
}

extension CourseRevenueView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.segmentedControl)
        self.insertSubview(self.pageControllerView, aboveSubview: self.headerView)
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
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            self.headerHeightConstraint = make.height.equalTo(self.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.segmentedControlHeight)
        }
    }
}
