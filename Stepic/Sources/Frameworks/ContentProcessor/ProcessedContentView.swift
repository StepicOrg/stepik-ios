import Atributika
import SnapKit
import UIKit

extension ProcessedContentView {
    struct Appearance {
        let labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let labelTextColor = UIColor.stepikSystemPrimaryText
    }
}

final class ProcessedContentView: UIView {
    typealias ContentProcessorBuilder = (String) -> ContentProcessorProtocol

    let appearance: Appearance

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
                break
            case .tag(let tag):
                if tag.name == "a",
                    let href = tag.attributes["href"],
                    let url = URL(string: href) {
                    break
                }
            default:
                break
            }
        }
        return label
    }()

    private let contentProcessorBuilder: ContentProcessorBuilder

    var processedContent: ProcessedContent? = nil {
        didSet {
            if oldValue == self.processedContent {
                return
            }

            guard let processedContent = self.processedContent else {
                return
            }

            switch processedContent {
            case .text(let textValue):
                print(textValue)
            case .html(let textValue):
                print(textValue)
            }
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        contentProcessorBuilder: @escaping ContentProcessorBuilder
    ) {
        self.appearance = appearance
        self.contentProcessorBuilder = contentProcessorBuilder

        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(_ text: String?) {
        if text?.isEmpty ?? true {
            self.processedContent = nil
        } else {
            let contentProcessor = self.contentProcessorBuilder(text ?? "")
            self.processedContent = contentProcessor.processContent()
        }
    }
}

extension ProcessedContentView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {}

    func makeConstraints() {}
}
