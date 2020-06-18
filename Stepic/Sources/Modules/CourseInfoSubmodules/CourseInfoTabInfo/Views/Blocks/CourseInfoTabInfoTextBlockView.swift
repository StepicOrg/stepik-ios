import Atributika
import SnapKit
import UIKit

extension CourseInfoTabInfoTextBlockView {
    struct Appearance {
        var headerViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 47)

        let messageLabelInsets = UIEdgeInsets(top: 16, left: 47, bottom: 30, right: 47)
        let messageLabelFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let messageLabelTextColor = UIColor.stepikSecondaryText

        let messageLabelLineSpacing: CGFloat = 2.6
    }
}

final class CourseInfoTabInfoTextBlockView: UIView {
    let appearance: Appearance

    private lazy var headerView = CourseInfoTabInfoHeaderBlockView()

    private lazy var messageLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        label.font = self.appearance.messageLabelFont
        label.textColor = self.appearance.messageLabelTextColor
        label.onClick = { [weak self] label, detection in
            guard let strongSelf = self else {
                return
            }

            switch detection.type {
            case .link(let url):
                strongSelf.onOpenURL?(url)
            case .tag(let tag):
                if tag.name == "a",
                    let href = tag.attributes["href"],
                    let url = URL(string: href) {
                    strongSelf.onOpenURL?(url)
                }
            default:
                break
            }
        }
        return label
    }()

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    var icon: UIImage? {
        didSet {
            self.headerView.icon = self.icon
        }
    }

    var title: String? {
        didSet {
            self.headerView.title = self.title
        }
    }

    var message: String? {
        didSet {
            if let trimmedMessage = self.message?.trimmingCharacters(in: .whitespacesAndNewlines) {
                self.messageLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(
                    htmlString: trimmedMessage
                ) as? AttributedText
            } else {
                self.messageLabel.attributedText = nil
            }
        }
    }

    var onOpenURL: ((URL) -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.htmlToAttributedStringConverter = HTMLToAttributedStringConverter(font: appearance.messageLabelFont)
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

extension CourseInfoTabInfoTextBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.messageLabel)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right).priority(999)
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.messageLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.messageLabelInsets.bottom)
            make.trailing.equalTo(self.headerView).priority(999)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.messageLabelInsets.top)
        }
    }
}
