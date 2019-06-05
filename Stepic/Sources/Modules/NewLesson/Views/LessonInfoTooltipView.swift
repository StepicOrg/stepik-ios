import SnapKit
import UIKit

extension LessonInfoTooltipView {
    struct Appearance {
        let iconSize = CGSize(width: 24, height: 24)
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let textColor = UIColor.white
        let labelIconSpacing: CGFloat = 14
        let labelsSpacing: CGFloat = 8
    }
}

// This view doesn't use Auto Layout due to tooltip library doesn't support Auto Layout
final class LessonInfoTooltipView: UIView {
    let appearance: Appearance

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var yOffset: CGFloat = 0
        for subview in self.subviews {
            subview.frame = CGRect(origin: CGPoint(x: 0, y: yOffset), size: subview.frame.size)
            yOffset += subview.frame.height + self.appearance.labelsSpacing
        }
    }

    override func sizeToFit() {
        super.sizeToFit()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let width = self.subviews.map { $0.frame.width }.max() ?? 0
        let height = self.subviews.map { $0.frame.maxY }.max() ?? 0
        self.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
    }

    private func makeLabelWithIcon(icon: UIImage?, text: String) -> UIView {
        let imageView = UIImageView(image: icon)

        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.text = text
        label.sizeToFit()

        let containerView = UIView()
        containerView.addSubview(imageView)
        imageView.frame = CGRect(origin: .zero, size: self.appearance.iconSize)
        containerView.addSubview(label)
        label.frame = CGRect(
            x: imageView.frame.maxX + self.appearance.labelIconSpacing,
            y: 0,
            width: label.frame.width,
            height: self.appearance.iconSize.height
        )
        containerView.frame = CGRect(origin: .zero, size: CGSize(width: label.frame.maxX, height: label.frame.height))

        return containerView
    }
}

extension LessonInfoTooltipView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(
            self.makeLabelWithIcon(icon: UIImage(named: "lesson-tooltip-info"), text: "3 балла за верное")
        )
        self.addSubview(
            self.makeLabelWithIcon(icon: UIImage(named: "lesson-tooltip-info"), text: "20 минут на решение")
        )
        self.addSubview(
            self.makeLabelWithIcon(icon: UIImage(named: "lesson-tooltip-info"), text: "94 балла до сертификата")
        )
    }
}
