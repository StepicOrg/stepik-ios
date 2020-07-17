import SnapKit
import UIKit

extension NewProfileBlockContainerView {
    struct Appearance {
        let separatorColor = UIColor.stepikSeparator
        let backgroundColor = UIColor.stepikSecondaryGroupedBackground

        let headerViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var contentViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let separatorViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

final class NewProfileBlockContainerView: UIView {
    let appearance: Appearance

    private let headerView: UIView & NewProfileBlockHeaderViewProtocol
    private let contentView: UIView
    private let shouldShowSeparator: Bool

    private let hasContentView: Bool

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var titleText: String? {
        get {
            self.headerView.titleText
        }
        set {
            self.headerView.titleText = newValue
        }
    }

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
        headerView: UIView & NewProfileBlockHeaderViewProtocol = NewProfileBlockHeaderView(),
        contentView: UIView?,
        shouldShowSeparator: Bool = false,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.headerView = headerView
        self.contentView = contentView ?? UIView()
        self.hasContentView = contentView != nil
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

    @objc
    private func showAllButtonClicked() {
        self.onShowAllButtonClick?()
    }
}

extension NewProfileBlockContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.contentView.clipsToBounds = false

        if let headerControl = self.headerView as? UIControl {
            headerControl.addTarget(self, action: #selector(self.showAllButtonClicked), for: .touchUpInside)
        }
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.contentView)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
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
                .offset(self.hasContentView ? -self.appearance.contentViewInsets.bottom : 0)
        }
    }
}
