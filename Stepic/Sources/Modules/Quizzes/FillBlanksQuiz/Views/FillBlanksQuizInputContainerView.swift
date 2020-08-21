import SnapKit
import UIKit

extension FillBlanksQuizInputContainerView {
    struct Appearance {
        var cornerRadius: CGFloat = 18
        let borderWidth: CGFloat = 1
    }
}

final class FillBlanksQuizInputContainerView: UIView {
    let appearance: Appearance

    var state = State.default {
        didSet {
            self.updateState()
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius

        self.updateState()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.performBlockIfAppearanceChanged(from: previousTraitCollection, block: self.updateState)
    }

    private func updateState() {
        self.backgroundColor = self.state.backgroundColor

        self.layer.borderColor = self.state.borderColor.cgColor
        self.layer.borderWidth = self.appearance.borderWidth
    }

    enum State {
        case `default`
        case correct
        case wrong

        var borderColor: UIColor {
            switch self {
            case .default:
                return .quizElementSelectedBorder
            case .correct:
                return .quizElementCorrectBorder
            case .wrong:
                return .quizElementWrongBorder
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .default:
                return .quizElementSelectedBackground
            case .correct:
                return .quizElementCorrectBackground
            case .wrong:
                return .quizElementWrongBackground
            }
        }
    }
}
