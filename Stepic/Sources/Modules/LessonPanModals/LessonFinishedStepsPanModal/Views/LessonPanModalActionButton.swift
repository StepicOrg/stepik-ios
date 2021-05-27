import SnapKit
import UIKit

extension LessonPanModalActionButton {
    struct Appearance {
        let font = Typography.bodyFont

        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 1
    }
}

final class LessonPanModalActionButton: UIButton {
    let style: Style
    let appearance: Appearance

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(
        frame: CGRect = .zero,
        style: Style = .default,
        appearance: Appearance = Appearance()
    ) {
        self.style = style
        self.appearance = appearance

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum Style {
        case fill
        case outline

        static var `default`: Style { .fill }

        fileprivate var titleColor: UIColor {
            switch self {
            case .fill:
                return .white
            case .outline:
                return .stepikGreenFixed
            }
        }

        fileprivate var borderColor: UIColor {
            switch self {
            case .fill:
                return .clear
            case .outline:
                return .stepikGreenFixed
            }
        }

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .outline:
                return .stepikBackground
            case .fill:
                return .stepikGreenFixed
            }
        }
    }
}

extension LessonPanModalActionButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.setTitleColor(self.style.titleColor, for: .normal)
        self.titleLabel?.font = self.appearance.font

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.clipsToBounds = true

        if self.style == .outline {
            self.layer.borderWidth = self.appearance.borderWidth
            self.layer.borderColor = self.style.borderColor.cgColor
        }

        self.backgroundColor = self.style.backgroundColor
    }
}
