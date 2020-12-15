import SnapKit
import UIKit

extension GridSimpleCourseListCollectionHeaderView {
    struct Appearance {
        let rightDetailImageViewSize = CGSize(width: 6, height: 12)
        let rightDetailImageViewTintColor = UIColor.stepikSystemSecondaryText
        let rightDetailImageViewInsets = LayoutInsets(right: 16)

        let titleLabelFont = Typography.title3Font
        let titleLabelTextColor = UIColor.stepikSystemPrimaryText
        let titleLabelInsets = LayoutInsets(top: 16, left: 16, right: 8)

        let subtitleLabelFont = Typography.calloutFont
        let subtitleLabelTextColor = UIColor.stepikSystemSecondaryText
        let subtitleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)

        let containerInsets = LayoutInsets(left: 20, right: 20)
        let cornerRadius: CGFloat = 13
    }
}

final class GridSimpleCourseListCollectionHeaderView: UICollectionReusableView, Reusable {
    let appearance = Appearance()

    private lazy var backgroundImageView: UIImageView = {
        //let image = UIImage(named: "course-list-simple-grid-placeholder")
        let image = UIImage(named: "placeholder_gradient_blue")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var rightDetailImageView: UIImageView = {
        let image = UIImage(named: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.rightDetailImageViewTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var containerView = UIView()

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

        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
    }

    func configure(viewModel: SimpleCourseListWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
    }
}

extension GridSimpleCourseListCollectionHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.containerView.layer.cornerRadius = self.appearance.cornerRadius
        self.containerView.layer.masksToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.backgroundImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        self.containerView.addSubview(self.rightDetailImageView)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.containerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.containerInsets.right)
        }

        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.rightDetailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.rightDetailImageViewInsets.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.rightDetailImageViewSize.width)
            make.height.equalTo(self.appearance.rightDetailImageViewSize.height)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalTo(self.rightDetailImageView.snp.leading)
                .offset(-self.appearance.titleLabelInsets.right)
        }
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.subtitleLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.right)
        }
        self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
