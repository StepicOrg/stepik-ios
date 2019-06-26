import UIKit

extension CourseWidgetLabel {
    struct Appearance {
        var maxLinesCount = 3
        var font = UIFont.systemFont(ofSize: 16, weight: .regular)
        var textColor = UIColor.mainText
    }
}

final class CourseWidgetLabel: UILabel {
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

extension CourseWidgetLabel: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.textColor = self.appearance.textColor
        self.font = self.appearance.font
        self.numberOfLines = self.appearance.maxLinesCount
    }
}
