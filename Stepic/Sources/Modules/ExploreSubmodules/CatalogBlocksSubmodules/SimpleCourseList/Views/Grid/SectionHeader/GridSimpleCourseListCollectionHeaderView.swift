import SnapKit
import UIKit

extension GridSimpleCourseListCollectionHeaderView {
    struct Appearance {
        let contentViewInsets = LayoutInsets(left: 20, right: 20)
        let cornerRadius: CGFloat = 13
    }
}

final class GridSimpleCourseListCollectionHeaderView: UICollectionReusableView, Reusable {
    let appearance = Appearance()

    private lazy var contentView: GridSimpleCourseListCollectionHeaderContentView = {
        let view = GridSimpleCourseListCollectionHeaderContentView()
        view.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
        return view
    }()

    var onTapCallback: (() -> Void)?

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

    override func prepareForReuse() {
        super.prepareForReuse()

        self.contentView.titleText = nil
        self.contentView.subtitleText = nil
    }

    func configure(viewModel: SimpleCourseListWidgetViewModel) {
        self.contentView.titleText = viewModel.title
        self.contentView.subtitleText = viewModel.subtitle
    }

    @objc
    private func handleTap() {
        self.onTapCallback?()
    }
}

extension GridSimpleCourseListCollectionHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.contentView.layer.cornerRadius = self.appearance.cornerRadius
        self.contentView.layer.masksToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.contentView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentViewInsets.right)
        }
    }
}
