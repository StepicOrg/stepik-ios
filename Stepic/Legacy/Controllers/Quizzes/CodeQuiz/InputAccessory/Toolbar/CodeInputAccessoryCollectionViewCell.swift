import SnapKit
import UIKit

extension CodeInputAccessoryCollectionViewCell {
    enum Appearance {
        static let textColor = UIColor.stepikSystemPrimaryText

        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let borderColor = UIColor.clear.cgColor

        static let backgroundColor = UIColor.stepikTertiaryBackground

        static let calculateWidthBoundsWidthPadding: CGFloat = 10
    }
}

final class CodeInputAccessoryCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var textLabel = Self.makeTextLabel()

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

    func configure(text: String, size: CodeInputAccessorySize) {
        self.textLabel.text = text
        self.textLabel.font = Self.makeFont(for: size)
    }

    static func calculateWidth(for text: String, size: CodeInputAccessorySize) -> CGFloat {
        let label = self.makeTextLabel(
            frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            size: size
        )
        label.text = text
        label.sizeToFit()
        return max(size.realSizes.minAccessoryWidth, label.bounds.width + Appearance.calculateWidthBoundsWidthPadding)
    }

    private static func makeTextLabel(frame: CGRect = .zero, size: CodeInputAccessorySize? = nil) -> UILabel {
        let label = UILabel(frame: frame)
        label.textColor = Appearance.textColor
        label.numberOfLines = 1
        label.textAlignment = .center

        if let size = size {
            label.font = self.makeFont(for: size)
        }

        return label
    }

    private static func makeFont(for size: CodeInputAccessorySize) -> UIFont {
        UIFont(name: "Courier", size: size.realSizes.textSize) ?? .systemFont(ofSize: size.realSizes.textSize)
    }
}

extension CodeInputAccessoryCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.borderWidth = Appearance.borderWidth
        self.layer.borderColor = Appearance.borderColor
        self.layer.masksToBounds = true

        self.backgroundColor = .stepikTertiaryBackground
    }

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
