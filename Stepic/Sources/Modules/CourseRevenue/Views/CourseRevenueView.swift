import SnapKit
import UIKit

protocol CourseRevenueViewDelegate: AnyObject {
    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didReportNewHeaderHeight height: CGFloat)
    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didRequestScrollToPage index: Int)
    func numberOfPages(in courseRevenueView: CourseRevenueView) -> Int
}

extension CourseRevenueView {
    struct Appearance {
        // Status bar + navbar + other offsets
        var headerTopOffset: CGFloat = 0.0
        let segmentedControlHeight: CGFloat = 48

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

    private lazy var headerView = CourseRevenueHeaderView()

    private lazy var segmentedControl: TabSegmentedControlView = {
        let control = TabSegmentedControlView(frame: .zero, items: self.tabsTitles)
        control.delegate = self
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

    func configure(viewModel: CourseRevenueHeaderViewModel) {
        self.headerView.configure(viewModel: viewModel)
        self.updateHeaderHeight(forceUpdate: true)
    }

    func updateScroll(offset: CGFloat) {
        self.topConstraint?.update(offset: -offset)
    }

    func updateCurrentPageIndex(_ index: Int) {
        self.currentPageIndex = index
        self.segmentedControl.selectTab(index: index)
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
            make.leading.trailing.equalToSuperview()
            self.headerHeightConstraint = make.height.equalTo(self.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(self.appearance.segmentedControlHeight)
        }
    }
}

extension CourseRevenueView: TabSegmentedControlViewDelegate {
    func tabSegmentedControlView(_ tabSegmentedControlView: TabSegmentedControlView, didSelectTabWithIndex index: Int) {
        let tabsCount = self.delegate?.numberOfPages(in: self) ?? 0
        guard index >= 0, index < tabsCount else {
            return
        }

        self.delegate?.courseRevenueView(self, didRequestScrollToPage: index)
        self.currentPageIndex = index
    }
}
