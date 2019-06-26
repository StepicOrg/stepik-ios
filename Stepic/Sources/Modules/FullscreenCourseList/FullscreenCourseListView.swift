import SnapKit
import UIKit

final class FullscreenCourseListView: UIView {
    private var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }

    func attachContentView(_ view: UIView) {
        self.contentView?.removeFromSuperview()

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
                make.width.equalTo(self.safeAreaLayoutGuide.snp.width)
            } else {
                make.leading.trailing.equalToSuperview()
                make.width.equalTo(self.snp.width)
            }
        }

        self.contentView = view
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
