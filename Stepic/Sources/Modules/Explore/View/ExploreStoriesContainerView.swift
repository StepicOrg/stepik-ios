import SnapKit
import UIKit

extension ExploreStoriesContainerView {
    struct Appearance {
        let storiesViewHeight: CGFloat = 98
        let storiesViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
}

final class ExploreStoriesContainerView: UIView {
    let appearance: Appearance

    private let contentView: UIView

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.storiesViewHeight)
    }

    init(
        frame: CGRect = .zero,
        contentView: UIView,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.contentView = contentView
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExploreStoriesContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.contentView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.storiesViewInsets.top)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.storiesViewHeight)
        }
    }
}
