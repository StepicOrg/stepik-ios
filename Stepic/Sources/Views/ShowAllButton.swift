import SnapKit
import UIKit

extension ShowAllButton {
    struct Appearance {
        let titleLabelTextColor = UIColor.stepikSystemTertiaryText
        let titleLabelFont = UIFont.systemFont(ofSize: 20, weight: .regular)

        let imageSize = CGSize(width: 11, height: 14)
        let imageTintColor = UIColor.stepikSystemTertiaryText

        let spacing: CGFloat = 8
    }
}

final class ShowAllButton: UIControl {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.text = NSLocalizedString("ShowAll", comment: "")
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.imageTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var imageViewLeadingConstraint: Constraint?

    var title: String? {
        didSet {
            self.titleLabel.isHidden = self.title == nil
            self.titleLabel.text = self.title
        }
    }

    var shouldShowDisclosureIndicator: Bool = true {
        didSet {
            self.imageView.isHidden = !self.shouldShowDisclosureIndicator
            self.imageViewLeadingConstraint?.update(
                offset: self.shouldShowDisclosureIndicator ? self.appearance.spacing : 0
            )
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let spacing = self.shouldShowDisclosureIndicator ? self.appearance.spacing : 0
        let imageWidth = self.shouldShowDisclosureIndicator ? self.appearance.imageSize.width : 0
        let width = self.titleLabel.frame.width + spacing + imageWidth

        let height = max(self.titleLabel.frame.height, self.appearance.imageSize.height)

        return CGSize(width: width, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

extension ShowAllButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            self.imageViewLeadingConstraint = make.leading
                .equalTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.spacing)
                .constraint
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.width.equalTo(self.appearance.imageSize.width)
            make.height.equalTo(self.appearance.imageSize.height)
        }
    }
}
