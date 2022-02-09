import UIKit

extension CourseInfoTabInfoLabel {
    struct Appearance {
        var maxLinesCount = 0
        var font = Typography.subheadlineFont
        var textColor = UIColor.stepikMaterialSecondaryText
    }
}

final class CourseInfoTabInfoLabel: UILabel {
    let appearance: Appearance

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoTabInfoLabel: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.textColor = self.appearance.textColor
        self.font = self.appearance.font
        self.numberOfLines = self.appearance.maxLinesCount
    }
}
