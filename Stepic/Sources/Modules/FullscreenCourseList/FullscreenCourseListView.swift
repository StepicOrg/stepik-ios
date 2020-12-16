import SnapKit
import UIKit

final class FullscreenCourseListView: UIView {
    private lazy var scrollableStackView = ScrollableStackView(orientation: .vertical)

    private var contentView: UIView?

    private var collectionViewContentSizeObservation: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .stepikBackground
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.collectionViewContentSizeObservation = nil
    }

    func insertBlockView(_ view: UIView, before previousView: UIView) {
        if self.subviews.isEmpty {
            return self.attachContentView(view)
        }

        if self.contentView === self.scrollableStackView {
            for (index, subview) in self.scrollableStackView.arrangedSubviews.enumerated()
                where subview === previousView {
                return self.scrollableStackView.insertArrangedView(view, at: index)
            }
            self.scrollableStackView.addArrangedView(view)
        } else {
            self.scrollableStackView.removeAllArrangedViews()

            if let contentView = self.contentView {
                self.scrollableStackView.addArrangedView(contentView)
                self.contentView = nil
            }

            self.attachContentView(self.scrollableStackView)
            self.insertBlockView(view, before: previousView)
        }
    }

    func removeBlockView(_ view: UIView) {
        if self.contentView === self.scrollableStackView {
            self.scrollableStackView.removeArrangedView(view)

            if self.scrollableStackView.arrangedSubviews.count == 1 {
                let subview = self.scrollableStackView.arrangedSubviews[0]
                self.scrollableStackView.removeAllArrangedViews()
                self.contentView = nil
                self.attachContentView(subview)
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }

    func observeCourseListCollectionViewContentSize(courseListView: UIView, collectionView: UICollectionView) {
        self.collectionViewContentSizeObservation = collectionView.observe(
            \.contentSize,
            options: [.old, .new],
            changeHandler: { [weak courseListView] _, change in
                let oldContentSize = change.oldValue
                let newContentSize = change.newValue

                if oldContentSize != newContentSize {
                    courseListView?.invalidateIntrinsicContentSize()
                }
            }
        )
    }

    private func attachContentView(_ view: UIView) {
        self.contentView?.removeFromSuperview()

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width)
        }

        self.contentView = view
    }
}
