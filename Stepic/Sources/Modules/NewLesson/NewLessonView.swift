import SnapKit
import UIKit

extension NewLessonView {
    struct Appearance { }
}

final class NewLessonView: UIView {
    let appearance: Appearance

    private lazy var scrollView = UIScrollView()
    private lazy var skeletonView = UIView()

    var contentInset: UIEdgeInsets {
        get {
            return self.scrollView.contentInset
        }
        set {
            self.scrollView.contentInset = newValue
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    func showLoading() {
        self.skeletonView.skeleton.viewBuilder = {
            StepControllerSkeletonView()
        }
        self.skeletonView.skeleton.show()
    }

    func hideLoading() {
        self.skeletonView.skeleton.hide()
    }
}

extension NewLessonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.skeletonView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.skeletonView.translatesAutoresizingMaskIntoConstraints = false
        self.skeletonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}
