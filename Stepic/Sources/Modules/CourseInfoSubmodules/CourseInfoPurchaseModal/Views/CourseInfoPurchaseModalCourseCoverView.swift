import SnapKit
import UIKit

extension CourseInfoPurchaseModalCourseCoverView {
    struct Appearance {
        let coverImageViewSize = CGSize(width: 48, height: 48)
        let coverImageViewCornerRadius: CGFloat = 8
        var coverImageViewInsets = LayoutInsets(top: 0, left: 16)

        let titleFont = UIFont.systemFont(ofSize: 19, weight: .semibold)
        let titleTextColor = UIColor.stepikMaterialPrimaryText
        var titleInsets = LayoutInsets(horizontal: 16)
    }
}

final class CourseInfoPurchaseModalCourseCoverView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.setRoundedCorners(cornerRadius: self.appearance.coverImageViewCornerRadius)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 0
        return label
    }()

    var coverURL: URL? {
        didSet {
            self.coverImageView.loadImage(url: self.coverURL)
        }
    }

    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.coverImageViewInsets.top
            + max(self.appearance.coverImageViewSize.height, self.titleLabel.intrinsicContentSize.height)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

extension CourseInfoPurchaseModalCourseCoverView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.coverImageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.coverImageViewInsets.left)
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.top)
            make.leading.equalTo(self.coverImageView.snp.trailing).offset(self.appearance.titleInsets.left)
            make.bottom.lessThanOrEqualToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }
    }
}
