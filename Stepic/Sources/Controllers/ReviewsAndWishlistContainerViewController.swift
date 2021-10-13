import SnapKit
import UIKit

extension ReviewsAndWishlistContainerViewController {
    enum Appearance {
        static let stackViewSpacing: CGFloat = 12
        static let stackViewHeight: CGFloat = 100
        static let stackViewInsets = UIEdgeInsets(top: 4, left: 20, bottom: 10, right: 28)
    }
}

final class ReviewsAndWishlistContainerViewController: UIViewController {
    private static let refreshDebounceInterval: TimeInterval = 1

    private let userCoursesReviewsWidgetAssembly: UserCoursesReviewsWidgetAssembly
    private let wishlistWidgetAssembly: WishlistWidgetAssembly

    private let refreshDebouncer = Debouncer(delay: ReviewsAndWishlistContainerViewController.refreshDebounceInterval)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Appearance.stackViewSpacing
        return stackView
    }()

    init() {
        self.userCoursesReviewsWidgetAssembly = UserCoursesReviewsWidgetAssembly()
        self.wishlistWidgetAssembly = WishlistWidgetAssembly()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    // MARK: Public API

    func refreshSubmodules() {
        self.refreshDebouncer.action = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.userCoursesReviewsWidgetAssembly.moduleInput?.refreshReviews()
            strongSelf.wishlistWidgetAssembly.moduleInput?.refreshWishlist()
        }
    }

    // MARK: Private API

    private func setup() {
        self.view.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.stackViewInsets)
            make.height.equalTo(Appearance.stackViewHeight)
        }

        [self.userCoursesReviewsWidgetAssembly, self.wishlistWidgetAssembly].forEach(self.registerSubmodule(assembly:))
    }

    private func registerSubmodule(assembly: Assembly) {
        let viewController = assembly.makeModule()

        self.addChild(viewController)
        self.stackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
