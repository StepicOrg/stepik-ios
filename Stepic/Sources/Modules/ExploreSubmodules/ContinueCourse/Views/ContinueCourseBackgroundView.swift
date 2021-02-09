import SnapKit
import UIKit

extension ContinueCourseBackgroundView {
    struct Appearance {
        let backgroundColor = UIColor.stepikSecondaryBackground
    }
}

final class ContinueCourseBackgroundView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "continue_learning_gradient"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateAppearance()
        }
    }

    private func updateAppearance() {
        self.backgroundColor = self.appearance.backgroundColor
        self.imageView.isHidden = self.isDarkInterfaceStyle
    }
}

extension ContinueCourseBackgroundView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateAppearance()
    }

    func addSubviews() {
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
