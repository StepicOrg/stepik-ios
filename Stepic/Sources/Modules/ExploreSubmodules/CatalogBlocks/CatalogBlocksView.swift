import SnapKit
import UIKit

extension CatalogBlocksView {
    struct Appearance {
        let skeletonViewHeight: CGFloat = 149

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CatalogBlocksView: UIView {
    let appearance: Appearance

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let contentStackViewHeight = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: contentStackViewHeight
        )
    }

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

    // MARK: Public API

    func addBlockView(_ view: UIView) {
        self.contentStackView.addArrangedSubview(view)
    }

    func removeAllBlocks() {
        self.contentStackView.removeAllArrangedSubviews()
    }

    func showLoading() {
        let fakeView = UIView()
        fakeView.translatesAutoresizingMaskIntoConstraints = false
        fakeView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.skeletonViewHeight)
        }
        self.contentStackView.addArrangedSubview(fakeView)

        fakeView.skeleton.viewBuilder = {
            CatalogBlocksSkeletonView()
        }
        fakeView.skeleton.show()
    }

    func hideLoading() {
        self.contentStackView.removeAllArrangedSubviews()
        self.contentStackView.skeleton.hide()
    }
}

extension CatalogBlocksView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.contentStackView)
    }

    func makeConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
