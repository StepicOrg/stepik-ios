import SnapKit
import UIKit

final class CourseListFilterBarButtonItem: UIBarButtonItem {
    private static let animationDuration: TimeInterval = 0.25

    private var contentView: CourseListFilterBarButtonItemContentView? {
        self.customView as? CourseListFilterBarButtonItemContentView
    }

    init(target: AnyObject, action: Selector) {
        super.init()

        let view = CourseListFilterBarButtonItemContentView()
        view.addTarget(target, action: action, for: .touchUpInside)

        self.customView = view
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ isActive: Bool) {
        UIView.animate(
            withDuration: Self.animationDuration,
            animations: {
                self.contentView?.isCircleHidden = !isActive
            }
        )
    }
}

// MARK: - CourseListFilterBarButtonItemContentView -

extension CourseListFilterBarButtonItemContentView {
    struct Appearance {
        let size = CGSize(width: 30, height: 24)

        let circleColor = UIColor.stepikVioletFixed
        let circleWidthHeight: CGFloat = 12
    }
}

final class CourseListFilterBarButtonItemContentView: UIControl {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "course-list-filter-slider")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.circleColor
        view.layer.cornerRadius = self.appearance.circleWidthHeight / 2
        view.isHidden = true
        return view
    }()

    var isCircleHidden: Bool {
        get {
            self.circleView.isHidden
        }
        set {
            self.circleView.isHidden = newValue
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.circleView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        self.appearance.size
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseListFilterBarButtonItemContentView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.circleView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.circleView.translatesAutoresizingMaskIntoConstraints = false
        self.circleView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.height.equalTo(self.appearance.circleWidthHeight)
        }
    }
}
