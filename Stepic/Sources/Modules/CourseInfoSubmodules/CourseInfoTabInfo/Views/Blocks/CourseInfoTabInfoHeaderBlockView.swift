import SnapKit
import UIKit

extension CourseInfoTabInfoHeaderBlockView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)
        let imageViewTintColor = UIColor.mainDark
        var imageViewLeadingSpace: CGFloat = 0

        var titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.mainDark
        var titleLabelInsets = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 0)
    }
}

final class CourseInfoTabInfoHeaderBlockView: UIView {
    let appearance: Appearance

    var icon: UIImage? {
        didSet {
            self.iconImageView.image = self.icon?.withRenderingMode(.alwaysTemplate)
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var attributedTitle: NSAttributedString? {
        didSet {
            self.titleLabel.attributedText = self.attributedTitle
        }
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
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

extension CourseInfoTabInfoHeaderBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageViewSize).priority(999)
            make.leading.equalToSuperview().offset(self.appearance.imageViewLeadingSpace)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left).priority(999)
            make.bottom.equalToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right).priority(999)
        }
    }
}
