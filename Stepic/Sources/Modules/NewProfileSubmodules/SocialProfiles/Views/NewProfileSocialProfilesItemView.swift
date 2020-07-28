import SnapKit
import UIKit

extension NewProfileSocialProfilesItemView {
    struct Appearance {
        let imageViewSize = CGSize(width: 28, height: 28)

        let textLabelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let textLabelTextColor = UIColor.stepikSystemPrimaryText
        let textLabelInsets = LayoutInsets(top: 0, left: 16, bottom: 0, right: 8)

        let accessoryViewSize = CGSize(width: 24, height: 24)
        let accessoryViewInsets = LayoutInsets(right: 20)

        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor.stepikSeparator
    }
}

final class NewProfileSocialProfilesItemView: UIControl {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var accessoryImageView: UIImageView = {
        var image: UIImage?
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "link")
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var isSeparatorHidden: Bool = false {
        didSet {
            self.separatorView.isHidden = self.isSeparatorHidden
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.accessoryImageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
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

extension NewProfileSocialProfilesItemView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
        self.addSubview(self.accessoryImageView)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.imageViewSize.width)
            make.height.equalTo(self.appearance.imageViewSize.height)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
            make.centerY.equalToSuperview()
            make.trailing
                .greaterThanOrEqualTo(self.accessoryImageView.snp.leading)
                .offset(-self.appearance.textLabelInsets.right)
        }

        self.accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        self.accessoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.accessoryViewInsets.right)
            make.width.equalTo(self.appearance.accessoryViewSize.width)
            make.height.equalTo(self.appearance.accessoryViewSize.height)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalTo(self.textLabel.snp.leading)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
