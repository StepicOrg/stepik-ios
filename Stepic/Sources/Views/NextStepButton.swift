import SnapKit
import UIKit

extension NextStepButton {
    struct Appearance {
        var font = UIFont.systemFont(ofSize: 16)

        var cornerRadius: CGFloat = 6
        var borderWidth: CGFloat = 1
    }
}

final class NextStepButton: UIButton {
    let appearance: Appearance

    var style: Style {
        didSet {
            self.updateStyle()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        style: Style = .filled
    ) {
        self.appearance = appearance
        self.style = style

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = self.style.borderColor.cgColor
    }

    private func updateStyle() {
        self.setTitleColor(self.style.titleColor, for: .normal)
        self.layer.borderColor = self.style.borderColor.cgColor
        self.backgroundColor = self.style.backgroundColor
    }

    enum Style {
        case filled
        case outlineDark

        fileprivate var titleColor: UIColor {
            switch self {
            case .filled:
                return .dynamic(light: .white, dark: .stepikGreen)
            case .outlineDark:
                return .stepikPrimaryText
            }
        }

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .filled:
                return .dynamic(light: .stepikGreen, dark: .stepikBackground)
            case .outlineDark:
                return .stepikBackground
            }
        }

        fileprivate var borderColor: UIColor {
            switch self {
            case .filled:
                return .dynamic(light: .clear, dark: .stepikGreen)
            case .outlineDark:
                return .stepikSeparator
            }
        }
    }
}

extension NextStepButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.setTitle(NSLocalizedString("NextStepNavigationTitle", comment: ""), for: .normal)
        self.titleLabel?.font = self.appearance.font

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.borderWidth = self.appearance.borderWidth
        self.clipsToBounds = true

        self.updateStyle()
    }
}
