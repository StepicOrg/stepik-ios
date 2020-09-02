import SnapKit
import UIKit

protocol NewProfileViewDelegate: AnyObject {
    func newProfileView(_ view: NewProfileView, didScroll scrollView: UIScrollView)
    func newProfileViewRefreshControlDidRefresh(_ view: NewProfileView)
}

extension NewProfileView {
    struct Appearance {
        let backgroundColor = UIColor.stepikGroupedBackground
        let stackViewSpacing: CGFloat = 20
    }
}

final class NewProfileView: UIView {
    weak var delegate: NewProfileViewDelegate?

    let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(orientation: .vertical)
        stackView.spacing = self.appearance.stackViewSpacing
        stackView.contentInsetAdjustmentBehavior = .never
        stackView.delegate = self
        stackView.scrollDelegate = self
        if #available(iOS 13.0, *) {
            stackView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return stackView
    }()

    private lazy var headerView = NewProfileHeaderView()

    private var storedViewModel: NewProfileViewModel?

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

    func showLoading() {
        let topContentInset = self.scrollableStackView.contentInsets.top
        self.skeleton.viewBuilder = {
            NewProfileHeaderViewSkeleton(topContentInset: topContentInset)
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }

    func endRefreshing() {
        self.scrollableStackView.endRefreshing()
    }

    func configure(viewModel: NewProfileViewModel) {
        self.storedViewModel = viewModel
        self.headerView.configure(viewModel: viewModel.headerViewModel)

        self.scrollableStackView.isRefreshControlEnabled = !viewModel.headerViewModel.isStretchyHeaderAvailable
    }

    // MARK: Blocks

    func removeBlockView(_ view: UIView) {
        self.scrollableStackView.removeArrangedView(view)
    }

    func insertBlockView(_ view: UIView, before previousView: UIView) {
        for (index, subview) in self.scrollableStackView.arrangedSubviews.enumerated() where subview === previousView {
            self.scrollableStackView.insertArrangedView(view, at: index)
            return
        }
        self.scrollableStackView.addArrangedView(view)
    }
}

extension NewProfileView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)

        self.scrollableStackView.addArrangedView(self.headerView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - NewProfileView: UIScrollViewDelegate -

extension NewProfileView: UIScrollViewDelegate {
    var contentInsets: UIEdgeInsets {
        get {
            self.scrollableStackView.contentInsets
        }
        set {
            self.scrollableStackView.contentInsets = newValue
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let storedViewModel = self.storedViewModel else {
            return
        }

        if storedViewModel.headerViewModel.isStretchyHeaderAvailable {
            let contentOffsetY = scrollView.contentOffset.y
            self.headerView.additionalCoverViewHeight = contentOffsetY > 0 ? 0 : (-contentOffsetY)
        }

        self.delegate?.newProfileView(self, didScroll: scrollView)
    }
}

// MARK: - NewProfileView: ScrollableStackViewDelegate -

extension NewProfileView: ScrollableStackViewDelegate {
    func scrollableStackViewRefreshControlDidRefresh(_ scrollableStackView: ScrollableStackView) {
        self.delegate?.newProfileViewRefreshControlDidRefresh(self)
    }
}
