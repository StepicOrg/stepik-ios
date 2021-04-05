import SnapKit
import UIKit

extension ExploreStepikAcademyBlockContainerView {
    struct Appearance {
        var backgroundColor = UIColor.stepikBackground

        let headerViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        let contentViewInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)

        let logoImageViewHeight: CGFloat = 102
        let logoImageViewInsets = LayoutInsets(bottom: 16)
    }
}

final class ExploreStepikAcademyBlockContainerView: UIView {
    let appearance: Appearance

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "academy-container-logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let headerView: UIView & ExploreBlockHeaderViewProtocol
    private let contentView: UIView

    var onShowAllButtonClick: (() -> Void)? {
        didSet {
            self.headerView.onShowAllButtonClick = self.onShowAllButtonClick
        }
    }

    override var intrinsicContentSize: CGSize {
        let logoHeightWithInsets = self.appearance.headerViewInsets.top + self.appearance.logoImageViewHeight
        let headerViewHeight = self.headerView.intrinsicContentSize.height

        let contentViewHeight = self.contentView.intrinsicContentSize.height
        let contentViewHeightWithInsets = contentViewHeight
            + self.appearance.contentViewInsets.top
            + self.appearance.contentViewInsets.bottom

        let finalHeight = logoHeightWithInsets
            - self.appearance.logoImageViewInsets.bottom
            + headerViewHeight
            + contentViewHeightWithInsets

        return CGSize(width: UIView.noIntrinsicMetric, height: finalHeight)
    }

    init(
        frame: CGRect = .zero,
        headerView: UIView & ExploreBlockHeaderViewProtocol,
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

extension ExploreStepikAcademyBlockContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.contentView.clipsToBounds = false
    }

    func addSubviews() {
        self.addSubview(self.logoImageView)
        self.addSubview(self.headerView)
        self.addSubview(self.contentView)
    }

    func makeConstraints() {
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.leading.equalToSuperview()
            make.height.equalTo(self.appearance.logoImageViewHeight)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalTo(self.logoImageView.snp.bottom).offset(-self.appearance.logoImageViewInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.contentViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.contentViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.contentViewInsets.right)
        }
    }
}
