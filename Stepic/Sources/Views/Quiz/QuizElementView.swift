import SnapKit
import UIKit

extension QuizElementView {
    struct Appearance {
        let cornerRadius: CGFloat = 6
        let borderWidth: CGFloat = 1
    }
}

final class QuizElementView: UIView {
    let appearance: Appearance

    var state = State.default {
        didSet {
            self.updateState()
        }
    }

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

    private func updateState() {
        self.backgroundColor = self.state.backgroundColor
        self.setRoundedCorners(
            cornerRadius: self.appearance.cornerRadius,
            borderWidth: self.appearance.borderWidth,
            borderColor: self.state.borderColor
        )
    }

    enum State {
        case `default`
        case correct
        case wrong
        case selected

        var borderColor: UIColor {
            switch self {
            case .default:
                return UIColor(hex: 0xCCCCCC)
            case .correct:
                return UIColor(hex: 0x66CC66).withAlphaComponent(0.5)
            case .wrong:
                return UIColor(hex: 0xFF7965).withAlphaComponent(0.5)
            case .selected:
                return UIColor(hex: 0x6C7BDF).withAlphaComponent(0.5)
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .default:
                return UIColor.white
            case .correct:
                return UIColor(hex: 0xECF8EC)
            case .wrong:
                return UIColor(hex: 0xFFEFEC)
            case .selected:
                return UIColor(hex: 0xEDEFFB)
            }
        }
    }
}

extension QuizElementView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateState()
    }
}
