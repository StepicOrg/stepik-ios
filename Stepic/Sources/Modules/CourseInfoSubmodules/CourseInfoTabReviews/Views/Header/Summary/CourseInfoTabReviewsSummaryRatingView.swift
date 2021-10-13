import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryRatingView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 48)
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let titleLabelInsets = LayoutInsets(bottom: 4)

        let clearStarsColor = UIColor.stepikMaterialDisabledText
        let starsSize = CGSize(width: 11, height: 11)
    }
}

final class CourseInfoTabReviewsSummaryRatingView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private lazy var starsView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.starClearColor = self.appearance.clearStarsColor
        appearance.starsSize = self.appearance.starsSize
        let view = CourseRatingView(appearance: appearance)
        return view
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var starsCount: Int = 0 {
        didSet {
            self.starsView.starsCount = self.starsCount
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleIntrinsicContentSize = self.titleLabel.intrinsicContentSize
        let starsIntrinsicContentSize = self.starsView.intrinsicContentSize

        let width = max(titleIntrinsicContentSize.width, starsIntrinsicContentSize.width)
        let height = titleIntrinsicContentSize.height
            + self.appearance.titleLabelInsets.bottom
            + starsIntrinsicContentSize.height

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

extension CourseInfoTabReviewsSummaryRatingView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.starsView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalTo(self.starsView.snp.top).offset(-self.appearance.titleLabelInsets.bottom)
            make.centerX.equalToSuperview()
        }

        self.starsView.translatesAutoresizingMaskIntoConstraints = false
        self.starsView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
