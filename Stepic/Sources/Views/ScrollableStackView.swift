import SnapKit
import UIKit

protocol ScrollableStackViewDelegate: AnyObject {
    func scrollableStackViewRefreshControlDidRefresh(_ scrollableStackView: ScrollableStackView)
}

final class ScrollableStackView: UIView {
    private let orientation: Orientation
    weak var delegate: ScrollableStackViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = self.orientation.stackViewOrientation
        return stackView
    }()

    private lazy var scrollView = UIScrollView()

    // MARK: - Refresh control

    var isRefreshControlEnabled: Bool = false {
        didSet {
            guard oldValue != self.isRefreshControlEnabled else {
                return
            }

            let refreshControl = self.isRefreshControlEnabled ? UIRefreshControl() : nil
            if let refreshControl = refreshControl {
                refreshControl.addTarget(
                    self,
                    action: #selector(self.onRefreshControlValueChanged),
                    for: .valueChanged
                )
            }

            self.scrollView.refreshControl = refreshControl
        }
    }

    private var refreshControl: UIRefreshControl? {
        self.scrollView.subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl
    }

    // MARK: - Blocks

    var arrangedSubviews: [UIView] {
        self.stackView.arrangedSubviews
    }

    // MARK: - Proxy properties

    var showsHorizontalScrollIndicator: Bool {
        get {
             self.scrollView.showsHorizontalScrollIndicator
        }
        set {
            self.scrollView.showsHorizontalScrollIndicator = newValue
        }
    }

    var showsVerticalScrollIndicator: Bool {
        get {
             self.scrollView.showsVerticalScrollIndicator
        }
        set {
            self.scrollView.showsVerticalScrollIndicator = newValue
        }
    }

    var spacing: CGFloat {
        get {
             self.stackView.spacing
        }
        set {
            self.stackView.spacing = newValue
        }
    }

    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
             self.scrollView.contentInsetAdjustmentBehavior
        }
        set {
            self.scrollView.contentInsetAdjustmentBehavior = newValue
        }
    }

    var scrollDelegate: UIScrollViewDelegate? {
        get {
             self.scrollView.delegate
        }
        set {
            self.scrollView.delegate = newValue
        }
    }

    var contentInsets: UIEdgeInsets {
        get {
             self.scrollView.contentInset
        }
        set {
            self.scrollView.contentInset = newValue
        }
    }

    var contentOffset: CGPoint {
        get {
             self.scrollView.contentOffset
        }
        set {
            self.scrollView.contentOffset = newValue
        }
    }

    var scrollIndicatorInsets: UIEdgeInsets {
        get {
             self.scrollView.scrollIndicatorInsets
        }
        set {
            self.scrollView.scrollIndicatorInsets = newValue
        }
    }

    var shouldBounce: Bool {
        get {
             self.scrollView.bounces
        }
        set {
            self.scrollView.bounces = newValue
        }
    }

    var isPagingEnabled: Bool {
        get {
             self.scrollView.isPagingEnabled
        }
        set {
            self.scrollView.isPagingEnabled = newValue
        }
    }

    var isScrollEnabled: Bool {
        get {
             self.scrollView.isScrollEnabled
        }
        set {
            self.scrollView.isScrollEnabled = newValue
        }
    }

    var contentSize: CGSize {
        get {
             self.scrollView.contentSize
        }
        set {
            self.scrollView.contentSize = newValue
        }
    }

    // MARK: - Inits

    init(frame: CGRect = .zero, orientation: Orientation) {
        self.orientation = orientation
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public interface

    func addArrangedView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }

    func removeArrangedView(_ view: UIView) {
        for subview in self.stackView.subviews where subview == view {
            self.stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    func insertArrangedView(_ view: UIView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
    }

    func removeAllArrangedViews() {
        for subview in self.stackView.subviews {
            self.removeArrangedView(subview)
        }
    }

    func startRefreshing() {
        self.refreshControl?.beginRefreshing()
    }

    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }

    func scrollTo(arrangedViewIndex: Int) {
        guard let targetFrame = self.arrangedSubviews[safe: arrangedViewIndex]?.frame else {
            return
        }

        self.scrollView.scrollRectToVisible(targetFrame, animated: true)
    }

    // MARK: - Private methods

    @objc
    private func onRefreshControlValueChanged() {
        self.delegate?.scrollableStackViewRefreshControlDidRefresh(self)
    }

    enum Orientation {
        case vertical
        case horizontal

        var stackViewOrientation: NSLayoutConstraint.Axis {
            switch self {
            case .vertical:
                return NSLayoutConstraint.Axis.vertical
            case .horizontal:
                return NSLayoutConstraint.Axis.horizontal
            }
        }
    }
}

extension ScrollableStackView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.stackView.clipsToBounds = false
        self.scrollView.clipsToBounds = false

        // For pull-to-refresh when contentSize is too small for scrolling
        if self.orientation == .horizontal {
            self.scrollView.alwaysBounceHorizontal = true
        } else {
            self.scrollView.alwaysBounceVertical = true
        }
        self.scrollView.bounces = true
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()

            if case .vertical = self.orientation {
                make.width.equalTo(self.scrollView.snp.width)
            } else {
                make.height.equalTo(self.scrollView.snp.height)
            }
        }
    }
}
