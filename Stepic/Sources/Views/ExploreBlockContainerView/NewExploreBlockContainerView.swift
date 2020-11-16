import SnapKit
import UIKit

extension NewExploreBlockContainerView {
    struct Appearance {
        var backgroundColor = UIColor.stepikBackground

        let headerViewInsets = UIEdgeInsets(top: 32, left: 20, bottom: 16, right: 20)
        var contentViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
}

final class NewExploreBlockContainerView: UIView {
    let appearance: Appearance

    private let headerView: (UIView & NewExploreBlockHeaderViewProtocol)?
    private let contentView: UIView

    var onShowAllButtonClick: (() -> Void)? {
        didSet {
            self.headerView?.onShowAllButtonClick = self.onShowAllButtonClick
        }
    }

    override var intrinsicContentSize: CGSize {
        let headerViewHeight = self.headerView?.intrinsicContentSize.height ?? 0
        let headerViewHeightWithInsets = headerViewHeight == 0
            ? 0
            : (headerViewHeight + self.appearance.headerViewInsets.top)

        let contentViewHeight = self.contentView.intrinsicContentSize.height
        let contentViewHeightWithInsets = contentViewHeight
            + self.appearance.contentViewInsets.top
            + self.appearance.contentViewInsets.bottom

        let finalHeight = headerViewHeightWithInsets + contentViewHeightWithInsets

        return CGSize(width: UIView.noIntrinsicMetric, height: finalHeight)
    }

    init(
        frame: CGRect = .zero,
        headerView: (UIView & NewExploreBlockHeaderViewProtocol)?,
        contentView: UIView,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.headerView = headerView
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension NewExploreBlockContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.contentView.clipsToBounds = false
    }

    func addSubviews() {
        if let headerView = self.headerView {
            self.addSubview(headerView)
        }

        self.addSubview(self.contentView)
    }

    func makeConstraints() {
        if let headerView = self.headerView {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
                make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
                make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
            }

            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.snp.makeConstraints { make in
                make.top
                    .equalTo(headerView.snp.bottom)
                    .offset(self.appearance.contentViewInsets.top)
                make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
                make.bottom.equalToSuperview().offset(-self.appearance.contentViewInsets.bottom)
                make.trailing.equalToSuperview().offset(-self.appearance.contentViewInsets.right)
            }
        } else {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(self.appearance.contentViewInsets.top)
                make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
                make.bottom.equalToSuperview().offset(-self.appearance.contentViewInsets.bottom)
                make.trailing.equalToSuperview().offset(-self.appearance.contentViewInsets.right)
            }
        }
    }
}
