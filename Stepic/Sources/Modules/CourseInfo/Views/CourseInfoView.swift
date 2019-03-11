import SnapKit
import UIKit

protocol CourseInfoViewDelegate: class {
    func courseInfoView(_ courseInfoView: CourseInfoView, reportNewHeaderHeight height: CGFloat)
    func courseInfoView(_ courseInfoView: CourseInfoView, requestScrollToPage index: Int)
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int
    func courseInfoViewDidMainAction(_ courseInfoView: CourseInfoView)
}

extension CourseInfoView {
    struct Appearance {
        // Status bar + navbar + other offsets
        var headerTopOffset: CGFloat = 0.0
        let segmentedControlHeight: CGFloat = 48.0

        let minimalHeaderHeight: CGFloat = 240
    }
}

final class CourseInfoView: UIView {
    let appearance: Appearance

    private let tabsTitles: [String]

    private var lastHeaderHeight: CGFloat = 0
    private var currentPageIndex = 0

    private lazy var headerView: CourseInfoHeaderView = {
        let view = CourseInfoHeaderView()
        view.onActionButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.courseInfoViewDidMainAction(strongSelf)
        }
        return view
    }()

    private lazy var segmentedControl: TabSegmentedControlView = {
        let control = TabSegmentedControlView(
            frame: .zero,
            items: self.tabsTitles
        )
        control.delegate = self
        return control
    }()

    private let pageControllerView: UIView

    // Dynamic scrolling constraints
    private var topConstraint: Constraint?
    private var headerHeightConstraint: Constraint?

    /// Real height for header
    var headerHeight: CGFloat {
        return max(
            0,
            self.lastHeaderHeight + self.appearance.headerTopOffset
        )
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

    func configure(viewModel: CourseInfoHeaderViewModel) {
        // Update header height
        self.lastHeaderHeight = self.headerView.calculateHeight(
            hasVerifiedMark: viewModel.isVerified
        )

        // Update data in header
        self.headerView.configure(viewModel: viewModel)

        self.delegate?.courseInfoView(
            self,
            reportNewHeaderHeight: self.headerHeight + self.appearance.segmentedControlHeight
        )
        self.headerHeightConstraint?.update(offset: self.headerHeight)
    }

    func updateScroll(offset: CGFloat) {
        // default position: offset == 0
        // overscroll (parallax effect): offset < 0
        // normal scrolling: offset > 0

        self.headerHeightConstraint?.update(
            offset: max(self.headerHeight, self.headerHeight + -offset)
        )

        self.topConstraint?.update(offset: min(0, -offset))
    }

    func updateCurrentPageIndex(_ index: Int) {
        self.currentPageIndex = index
        self.segmentedControl.selectTab(index: index)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Dispatch hits to correct views

        let convertedPoint = self.convert(point, to: self.headerView)
        if self.headerView.bounds.contains(convertedPoint) {
            // Pass hits to header subviews
            for subview in self.headerView.subviews.reversed() {
                // Skip subview-receiver if it has isUserInteractionEnabled == false
                // to pass some hits to scrollview (e.g. swipes in header area)
                let shouldSubviewInteract = subview.isUserInteractionEnabled
                if subview.frame.contains(convertedPoint) && shouldSubviewInteract {
                    return subview
                }
            }
        }

        return super.hitTest(point, with: event)
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
        self.backgroundColor = .white
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

            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            } else {
                make.leading.trailing.equalToSuperview()
            }
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            self.topConstraint = make.top.equalToSuperview().constraint
            make.left.right.equalToSuperview()
            self.headerHeightConstraint = make.height.equalTo(self.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)

            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            } else {
                make.leading.trailing.equalToSuperview()
            }

            make.height.equalTo(self.appearance.segmentedControlHeight)
        }
    }
}

extension CourseInfoView: TabSegmentedControlViewDelegate {
    func tabSegmentedControlView(
        _ tabSegmentedControlView: TabSegmentedControlView,
        didSelectTabWithIndex: Int
    ) {
        let tabsCount = self.delegate?.numberOfPages(in: self) ?? 0
        guard didSelectTabWithIndex >= 0,
              didSelectTabWithIndex < tabsCount else {
            return
        }

        self.delegate?.courseInfoView(self, requestScrollToPage: didSelectTabWithIndex)
        self.currentPageIndex = didSelectTabWithIndex
    }
}
