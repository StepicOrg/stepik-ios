import SnapKit
import UIKit

extension FillBlanksTextCollectionViewCell {
    struct Appearance {
        let font = UIFont.systemFont(ofSize: 16)
    }
}

final class FillBlanksTextCollectionViewCell: UICollectionViewCell, Reusable {
    private static var prototypeTextLabel: UILabel?

    private lazy var textLabel: UILabel = {
        Self.makeTextLabel(appearance: self.appearance)
    }()

    var appearance = Appearance()

    var text: String? {
        didSet {
            if let text = self.text {
                self.textLabel.setTextWithHTMLString(text)
            } else {
                self.textLabel.text = nil
            }
        }
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

    deinit {
        Self.prototypeTextLabel = nil
    }

    static func calculatePreferredContentSize(text: String, maxWidth: CGFloat) -> CGSize {
        if Self.prototypeTextLabel == nil {
            Self.prototypeTextLabel = Self.makeTextLabel()
        }

        guard let label = Self.prototypeTextLabel else {
            return .zero
        }

        label.frame = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)

        label.setTextWithHTMLString(text)
        label.sizeToFit()

        return label.bounds.size
    }

    private static func makeTextLabel(appearance: Appearance = Appearance()) -> UILabel {
        let label = UILabel()
        label.font = appearance.font
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
}

extension FillBlanksTextCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
