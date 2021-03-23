import SnapKit
import UIKit

extension StoryPartTitleLabel {
    struct Appearance {
        var textColor = UIColor.white
        let font = UIFont.systemFont(ofSize: 26, weight: .bold)
        let textAlignment = NSTextAlignment.left
        let numberOfLines = 0
    }
}

final class StoryPartTitleLabel: UILabel {
    let appearance: Appearance

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StoryPartTitleLabel: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.textColor = self.appearance.textColor
        self.font = self.appearance.font
        self.textAlignment = self.appearance.textAlignment
        self.numberOfLines = self.appearance.numberOfLines
    }
}
