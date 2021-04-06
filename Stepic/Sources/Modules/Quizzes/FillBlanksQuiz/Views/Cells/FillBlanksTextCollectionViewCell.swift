import SnapKit
import UIKit

extension FillBlanksTextCollectionViewCell {
    struct Appearance {
        let font = UIFont.systemFont(ofSize: 16)
        let textColor = UIColor.stepikPrimaryText
    }
}

final class FillBlanksTextCollectionViewCell: UICollectionViewCell, Reusable {
    private static let cache = Cache()

    private lazy var textContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.font,
            labelTextColor: self.appearance.textColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let contentProcessor = ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: self.appearance.font),
                TextColorInjection(dynamicColor: self.appearance.textColor)
            ]
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: contentProcessor,
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(font: self.appearance.font)
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    private var heightConstraint: Constraint?

    var appearance = Appearance()

    var onContentLoaded: ((CGSize) -> Void)?

    var text: String? {
        didSet {
            self.textContentView.setText(self.text)
        }
    }

    deinit {
        Self.cache.clear()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func calculatePreferredContentSize(text: String, maxWidth: CGFloat) -> CGSize {
//        if Self.prototypeTextLabel == nil {
//            Self.prototypeTextLabel = Self.makeTextLabel()
//        }
//
//        guard let label = Self.prototypeTextLabel else {
//            return .zero
//        }
//
//        label.frame = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
//
//        label.setTextWithHTMLString(text)
//        label.sizeToFit()
//
//        var size = label.bounds.size
//        size.width = size.width.rounded(.up)
//        size.height = size.height.rounded(.up)
//
//        return size

        return .zero
    }

    func calculatePreferredContentSize(text: String, maxWidth: CGFloat) -> CGSize {
        if text.isEmpty {
            return .zero
        }

        if let cachedSize = Self.cache.getSize(for: text) {
            return cachedSize
        } else {
            let maxSize = CGSize(width: maxWidth, height: 5)
            Self.cache.setMaxSize(maxSize, for: text)

            let preferredContentSize = self.textContentView.sizeThatFits(maxSize)
            Self.cache.setSize(preferredContentSize, for: text)

            return preferredContentSize
        }
    }

    private struct Cache {
        @Protected
        private var map: [Int: CGSize] = [:]

        @Protected
        private var maxSizeMap: [Int: CGSize] = [:]

        func getSize(for text: String?) -> CGSize? {
            guard let text = text else {
                return .zero
            }

            return self.$map.read({ $0[text.hashValue] })
        }

        func setSize(_ size: CGSize, for text: String?) {
            guard let text = text else {
                return
            }

            self.$map.write({ $0[text.hashValue] = size })
        }

        func getMaxSize(for text: String?) -> CGSize? {
            guard let text = text else {
                return .zero
            }

            return self.$maxSizeMap.read({ $0[text.hashValue] })
        }

        func setMaxSize(_ size: CGSize, for text: String?) {
            guard let text = text else {
                return
            }

            self.$maxSizeMap.write({ $0[text.hashValue] = size })
        }

        func clear() {
            self.$map.write({ $0.removeAll() })
            self.$maxSizeMap.write({ $0.removeAll() })
        }
    }
}

extension FillBlanksTextCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.textContentView)
    }

    func makeConstraints() {
        self.textContentView.translatesAutoresizingMaskIntoConstraints = false
        self.textContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.heightConstraint = make.height.equalTo(5).constraint
        }
    }
}

extension FillBlanksTextCollectionViewCell: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        guard let maxSize = Self.cache.getMaxSize(for: self.text) else {
            return
        }

        let newPreferredContentSize = self.textContentView.sizeThatFits(maxSize)
        if Self.cache.getSize(for: self.text) != newPreferredContentSize {
            Self.cache.setSize(newPreferredContentSize, for: self.text)
            self.onContentLoaded?(newPreferredContentSize)
        }
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        guard let maxSize = Self.cache.getMaxSize(for: self.text) else {
            return
        }

        self.heightConstraint?.update(offset: height)

        let newPreferredContentSize = self.textContentView.sizeThatFits(maxSize)
        if Self.cache.getSize(for: self.text) != newPreferredContentSize {
            Self.cache.setSize(newPreferredContentSize, for: self.text)
            self.onContentLoaded?(newPreferredContentSize)
        }
    }
}
