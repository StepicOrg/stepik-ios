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
    private let userCoursesReviewsBlockAssembly: UserCoursesReviewsBlockAssembly
    private let wishlistWidgetAssembly: WishlistWidgetAssembly

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Appearance.stackViewSpacing
        return stackView
    }()

    init() {
        self.userCoursesReviewsBlockAssembly = UserCoursesReviewsBlockAssembly()
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
        self.userCoursesReviewsBlockAssembly.moduleInput?.refreshUserCoursesReviews()
        self.wishlistWidgetAssembly.moduleInput?.refreshWishlist()
    }

    // MARK: Private API

    private func setup() {
        self.view.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.stackViewInsets)
            make.height.equalTo(Appearance.stackViewHeight)
        }

        [self.userCoursesReviewsBlockAssembly, self.wishlistWidgetAssembly].forEach(self.registerChildModule(assembly:))
    }

    private func registerChildModule(assembly: Assembly) {
        let viewController = assembly.makeModule()

        self.addChild(viewController)
        self.stackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
