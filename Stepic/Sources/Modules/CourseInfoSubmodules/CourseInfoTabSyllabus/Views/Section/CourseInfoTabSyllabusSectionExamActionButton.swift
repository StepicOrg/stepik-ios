import SnapKit
import UIKit

extension CourseInfoTabSyllabusSectionExamActionButton {
    struct Appearance {
        let titleColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
        let font = Typography.bodyFont

        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 1
        let borderColor = UIColor.stepikVioletFixed.withAlphaComponent(0.38)
    }
}

final class CourseInfoTabSyllabusSectionExamActionButton: UIButton {
    let appearance: Appearance

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = self.appearance.borderColor.cgColor
    }
}

extension CourseInfoTabSyllabusSectionExamActionButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.setTitleColor(self.appearance.titleColor, for: .normal)
        self.titleLabel?.font = self.appearance.font

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.borderWidth = self.appearance.borderWidth
        self.layer.borderColor = self.appearance.borderColor.cgColor
        self.clipsToBounds = true
    }
}
