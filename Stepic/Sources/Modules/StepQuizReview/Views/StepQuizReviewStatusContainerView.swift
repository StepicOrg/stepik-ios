import SnapKit
import UIKit

extension StepQuizReviewStatusContainerView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let headerViewInsets = UIEdgeInsets.zero
        var contentViewInsets = UIEdgeInsets(top: 16, left: 56, bottom: 16, right: 16)
        let separatorViewInsets = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)

        let separatorColor = UIColor.stepikSeparator
        let separatorHeight: CGFloat = 0.5
    }
}

final class StepQuizReviewStatusContainerView: UIView {
    let appearance: Appearance

    private let headerView: StepQuizReviewStatusView
    private let contentView: UIView?
    private let shouldShowSeparator: Bool

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var anchorView: UIView { self.headerView.anchorView }

    override var intrinsicContentSize: CGSize {
        let headerViewHeightWithTopInset = self.appearance.headerViewInsets.top
            + self.headerView.intrinsicContentSize.height
        let separatorHeight = self.shouldShowSeparator ? self.appearance.separatorHeight : 0

        let height: CGFloat

        if let contentView = self.contentView {
            height = headerViewHeightWithTopInset
                + self.appearance.contentViewInsets.top
                + contentView.intrinsicContentSize.height
                + self.appearance.contentViewInsets.bottom
                + separatorHeight
        } else {
            height = headerViewHeightWithTopInset
                + self.appearance.headerViewInsets.bottom
                + separatorHeight
        }

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        headerView: StepQuizReviewStatusView,
        contentView: UIView? = nil,
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
}

extension StepQuizReviewStatusContainerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.headerView.clipsToBounds = false
        if let contentView = self.contentView {
            contentView.clipsToBounds = false
        }
    }

    func addSubviews() {
        self.addSubview(self.headerView)

        if let contentView = self.contentView {
            self.addSubview(contentView)
        }

        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.headerViewInsets)

            if self.contentView == nil {
                make.bottom.equalTo(self.separatorView.snp.top).offset(-self.appearance.headerViewInsets.bottom)
            }
        }

        if let contentView = self.contentView {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.snp.makeConstraints { make in
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

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.separatorViewInsets)
            make.height.equalTo(self.shouldShowSeparator ? self.appearance.separatorHeight : 0)
        }
    }
}
