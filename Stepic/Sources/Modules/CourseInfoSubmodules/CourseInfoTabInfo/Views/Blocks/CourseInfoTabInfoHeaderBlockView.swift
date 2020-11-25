import Atributika
import SnapKit
import UIKit

extension CourseInfoTabInfoHeaderBlockView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)
        let imageViewTintColor = UIColor.stepikAccent
        var imageViewLeadingSpace: CGFloat = 0

        var titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.stepikPrimaryText
        var titleLabelInsets = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 0)
        var titleLabelNumberOfLines = 1
    }
}

final class CourseInfoTabInfoHeaderBlockView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var titleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = self.appearance.titleLabelNumberOfLines
        label.onClick = { [weak self] _, detection in
            guard let strongSelf = self else {
                return
            }

            switch detection.type {
            case .tag(let tag):
                if tag.name == "a",
                   let href = tag.attributes["href"] {
                    strongSelf.onTagClick?(href)
                }
            default:
                break
            }
        }
        return label
    }()

    var icon: UIImage? {
        didSet {
            self.iconImageView.image = self.icon?.withRenderingMode(.alwaysTemplate)
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.attributedText = self.title?.styleAll(Style())
        }
    }

    var attributedText: AttributedText? {
        didSet {
            self.titleLabel.attributedText = self.attributedText
        }
    }

    var onTagClick: ((String) -> Void)?

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
        self.backgroundColor = .clear
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

            let titleFirstLineCenterOffset = max(
                0,
                (self.appearance.titleLabelFont.lineHeight / 2) - (self.appearance.imageViewSize.height / 2)
            )
            make.top.equalToSuperview().offset(titleFirstLineCenterOffset)
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
