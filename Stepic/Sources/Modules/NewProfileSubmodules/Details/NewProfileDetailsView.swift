import Atributika
import SnapKit
import UIKit

protocol NewProfileDetailsViewDelegate: AnyObject {
    func newProfileDetailsView(_ view: NewProfileDetailsView, didOpenURL url: URL)
}

extension NewProfileDetailsView {
    struct Appearance {
        let labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let labelTextColor = UIColor.stepikSystemPrimaryText

        let backgroundColor = UIColor.stepikBackground
    }
}

final class NewProfileDetailsView: UIView {
    let appearance: Appearance

    weak var delegate: NewProfileDetailsViewDelegate?

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    private lazy var attributedLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.onClick = { [weak self] label, detection in
            guard let strongSelf = self else {
                return
            }

            switch detection.type {
            case .link(let url):
                strongSelf.delegate?.newProfileDetailsView(strongSelf, didOpenURL: url)
            case .tag(let tag):
                if tag.name == "a",
                   let href = tag.attributes["href"],
                   let url = URL(string: href) {
                    strongSelf.delegate?.newProfileDetailsView(strongSelf, didOpenURL: url)
                }
            default:
                break
            }
        }
        return label
    }()

    var text: String? {
        didSet {
            if let text = self.text {
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                self.attributedLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(
                    htmlString: trimmedText
                ) as? AttributedText
            } else {
                self.attributedLabel.attributedText = nil
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.attributedLabel.intrinsicContentSize.height
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.htmlToAttributedStringConverter = HTMLToAttributedStringConverter(font: appearance.labelFont)
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

extension NewProfileDetailsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.attributedLabel)
    }

    func makeConstraints() {
        self.attributedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.attributedLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
