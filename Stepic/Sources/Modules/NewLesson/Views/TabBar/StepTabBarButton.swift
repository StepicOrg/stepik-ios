import SnapKit
import Tabman
import UIKit

final class StepTabBarButton: TMBarButton {
    static let didMarkAsDone = Foundation.Notification.Name("StepTabBarButton.didMarkAsDone")
    static let userInfoIDKey = "stepID"
    static let animationDuration: TimeInterval = 0.25

    enum Appearance {
        static let size = CGSize(width: 72, height: 42)
        static let imageSize = CGSize(width: 24, height: 24)

        static let passedMarkSize = CGSize(width: 15, height: 15)
        static let passedMarkOffset = CGPoint(x: 9, y: 9)
    }

    private lazy var imageView = UIImageView()
    private lazy var passedMarkImageView = UIImageView(image: UIImage(named: "ic_solved_task_light"))

    private var passedMarkWidthConstraint: Constraint?
    private var passedMarkHeightConstraint: Constraint?

    private var identifier: String?

    override var intrinsicContentSize: CGSize {
        return Appearance.size
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layout(in view: UIView) {
        super.layout(in: view)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.markedAsDone(_:)),
            name: StepTabBarButton.didMarkAsDone,
            object: nil
        )

        view.addSubview(self.imageView)
        view.addSubview(self.passedMarkImageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Appearance.imageSize)
        }

        self.passedMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        self.passedMarkImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.imageView).offset(Appearance.passedMarkOffset.x)
            make.centerY.equalTo(self.imageView).offset(Appearance.passedMarkOffset.y)
            self.passedMarkWidthConstraint = make.width.equalTo(0).constraint
            self.passedMarkHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        self.identifier = item.title
        self.imageView.image = item.image

        if item.badgeValue != nil {
            self.passedMarkWidthConstraint?.update(offset: Appearance.passedMarkSize.width)
            self.passedMarkHeightConstraint?.update(offset: Appearance.passedMarkSize.height)

            self.passedMarkImageView.setNeedsLayout()
            self.passedMarkImageView.layoutIfNeeded()
        }
    }

    private func animatePassedMark() {
        self.passedMarkWidthConstraint?.update(offset: Appearance.passedMarkSize.width)
        self.passedMarkHeightConstraint?.update(offset: Appearance.passedMarkSize.height)
        self.passedMarkImageView.setNeedsLayout()

        UIView.animate(
            withDuration: StepTabBarButton.animationDuration,
            animations: {
                self.passedMarkImageView.layoutIfNeeded()
            }
        )
    }

    @objc
    private func markedAsDone(_ notification: Foundation.Notification) {
        guard let stepID = notification.userInfo?[StepTabBarButton.userInfoIDKey] as? String else {
            return
        }

        guard stepID == self.identifier else {
            return
        }

        self.animatePassedMark()
    }
}
