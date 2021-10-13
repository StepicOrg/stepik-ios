import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryDistributionCountItemView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 11)
        let titleLabelTextColor = UIColor.stepikMaterialSecondaryText

        let starsSpacing: CGFloat = 3
        let starsSize = CGSize(width: 5, height: 5)
        let starsInsets = LayoutInsets(left: 8)
    }
}

final class CourseInfoTabReviewsSummaryDistributionCountItemView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    private lazy var starsView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.starClearColor = .clear
        appearance.starsSpacing = self.appearance.starsSpacing
        appearance.starsSize = self.appearance.starsSize
        let view = CourseRatingView(appearance: appearance)
        return view
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.invalidateIntrinsicContentSize()
        }
    }

    var starsCount: Int = 0 {
        didSet {
            self.starsView.starsCount = self.starsCount
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleIntrinsicContentSize = self.titleLabel.intrinsicContentSize
        let starsIntrinsicContentSize = self.starsView.intrinsicContentSize

        let width = titleIntrinsicContentSize.width
            + self.appearance.starsInsets.left
            + starsIntrinsicContentSize.width
        let height = max(titleIntrinsicContentSize.height, starsIntrinsicContentSize.height)

        return CGSize(width: width, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoTabReviewsSummaryDistributionCountItemView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.starsView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.titleLabelFont.pointSize)
        }

        self.starsView.translatesAutoresizingMaskIntoConstraints = false
        self.starsView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(self.appearance.starsInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
    }
}
