import SnapKit
import UIKit

extension ExploreBlockContainerView {
    struct Appearance {
        let separatorColor = UIColor.stepikSeparator
        var background = Background.default

        var headerViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        var contentViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        let separatorViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        enum Background {
            case color(UIColor)
            case image(UIImage?)

            static var `default`: Background { .color(.stepikBackground) }
        }
    }
}

final class ExploreBlockContainerView: UIView {
    let appearance: Appearance
    private let headerView: UIView & ExploreBlockHeaderViewProtocol
    private let contentView: UIView
    private let shouldShowSeparator: Bool

    private lazy var backgroundImageView: UIImageView = {
        let image: UIImage? = {
            if case .image(let backgroundImage) = self.appearance.background {
                return backgroundImage
            }
            return nil
        }()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private var backgroundImageViewBottomToSuperviewConstraint: Constraint?
    private var backgroundImageViewBottomToContentViewConstraint: Constraint?

    var onShowAllButtonClick: (() -> Void)? {
        didSet {
            self.headerView.onShowAllButtonClick = self.onShowAllButtonClick
        }
    }

    override var intrinsicContentSize: CGSize {
        let headerViewHeight = self.headerView.intrinsicContentSize.height
        let paddingHeight = self.appearance.contentViewInsets.top
            + self.appearance.contentViewInsets.bottom
            + (self.shouldShowSeparator ? 1.0 : 0.0)
        let contentViewHeight = self.contentView.intrinsicContentSize.height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: headerViewHeight + paddingHeight + contentViewHeight
        )
    }

    init(
        frame: CGRect = .zero,
        headerView: UIView & ExploreBlockHeaderViewProtocol,
        contentView: UIView,
        shouldShowSeparator: Bool = false,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.headerView = headerView
        self.contentView = contentView
        self.shouldShowSeparator = shouldShowSeparator
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateBackgroundImageViewBottomConstraint()
        }
    }

    private func updateBackgroundImageViewBottomConstraint() {
        if self.isDarkInterfaceStyle {
            self.backgroundImageViewBottomToSuperviewConstraint?.deactivate()
            self.backgroundImageViewBottomToContentViewConstraint?.activate()
        } else {
            self.backgroundImageViewBottomToSuperviewConstraint?.activate()
            self.backgroundImageViewBottomToContentViewConstraint?.deactivate()
        }
    }
}

extension ExploreBlockContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.contentView.clipsToBounds = false

        if case .color(let backgroundColor) = self.appearance.background {
            self.backgroundColor = backgroundColor
        }
    }

    func addSubviews() {
        if case .image = self.appearance.background {
            self.addSubview(self.backgroundImageView)
        }

        self.addSubview(self.headerView)
        self.addSubview(self.contentView)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        if case .image = self.appearance.background {
            self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundImageView.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()

                self.backgroundImageViewBottomToSuperviewConstraint = make
                    .bottom.equalToSuperview().priority(.low).constraint
                self.backgroundImageViewBottomToContentViewConstraint = make
                    .bottom.equalTo(self.contentView.snp.bottom).constraint
                self.updateBackgroundImageViewBottomConstraint()
            }
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(self.shouldShowSeparator ? 0.5 : 0.0)
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top
                .equalTo(self.headerView.snp.bottom)
                .offset(self.appearance.contentViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.contentViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentViewInsets.right)
            make.bottom
                .equalTo(self.separatorView.snp.top)
                .offset(-self.appearance.contentViewInsets.bottom)
        }
    }
}
