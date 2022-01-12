import SnapKit
import UIKit

protocol BaseExploreViewDelegate: AnyObject {
    func refreshControlDidRefresh()
}

final class BaseExploreView: UIView {
    private lazy var scrollableStackView = ScrollableStackView(orientation: .vertical)
    weak var delegate: BaseExploreViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Blocks

    func addBlockView(_ view: UIView) {
        self.scrollableStackView.addArrangedView(view)
    }

    func removeBlockView(_ view: UIView) {
        if self.scrollableStackView.arrangedSubviews.contains(view) {
            self.scrollableStackView.removeArrangedView(view)
        } else {
            view.removeFromSuperview()
        }
    }

    func insertBlockView(_ view: UIView, at position: Int) {
        self.scrollableStackView.insertArrangedView(view, at: position)
    }

    func insertBlockView(_ view: UIView, before previousView: UIView) {
        for (index, subview) in self.scrollableStackView.arrangedSubviews.enumerated() where subview === previousView {
            self.scrollableStackView.insertArrangedView(view, at: index)
            return
        }
        self.scrollableStackView.addArrangedView(view)
    }

    // MARK: - Refresh control

    func endRefreshing() {
        self.scrollableStackView.endRefreshing()
    }
}

extension BaseExploreView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .stepikBackground

        self.scrollableStackView.delegate = self
        self.scrollableStackView.isRefreshControlEnabled = true
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

extension BaseExploreView: ScrollableStackViewDelegate {
    var contentInsets: UIEdgeInsets {
        get {
            self.scrollableStackView.contentInsets
        }
        set {
            self.scrollableStackView.contentInsets = newValue
        }
    }

    func scrollableStackViewRefreshControlDidRefresh(_ scrollableStackView: ScrollableStackView) {
        self.delegate?.refreshControlDidRefresh()
    }
}
