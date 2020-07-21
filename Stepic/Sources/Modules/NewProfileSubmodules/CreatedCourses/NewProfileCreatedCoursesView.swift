import SnapKit
import UIKit

extension NewProfileCreatedCoursesView {
    struct Appearance {}
}

final class NewProfileCreatedCoursesView: UIView {
    let appearance: Appearance

    private var contentView: UIView?

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attachContentView(_ view: UIView) {
        self.contentView?.removeFromSuperview()

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        self.contentView = view
    }
}
