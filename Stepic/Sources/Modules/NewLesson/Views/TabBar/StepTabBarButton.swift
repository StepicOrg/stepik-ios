import SnapKit
import Tabman
import UIKit

final class StepTabBarButton: TMBarButton {
    enum Appearance {
        static let size = CGSize(width: 72, height: 42)
        static let imageSize = CGSize(width: 24, height: 24)
    }

    private lazy var imageView = UIImageView()

    override var intrinsicContentSize: CGSize {
        return Appearance.size
    }

    override func layout(in view: UIView) {
        super.layout(in: view)

        view.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Appearance.imageSize)
        }
    }

    override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        self.imageView.image = item.image
    }
}
