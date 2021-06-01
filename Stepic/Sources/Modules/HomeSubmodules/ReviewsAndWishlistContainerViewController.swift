import SnapKit
import UIKit

extension ReviewsAndWishlistContainerViewController {
    enum Appearance {
        static let stackViewSpacing: CGFloat = 12
        static let stackViewHeight: CGFloat = 100
        static let stackViewInsets = UIEdgeInsets(top: 4, left: 20, bottom: 10, right: 20)
    }
}

final class ReviewsAndWishlistContainerViewController: UIViewController {
    private let userCoursesReviewsBlockAssembly: UserCoursesReviewsBlockAssembly

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Appearance.stackViewSpacing
        return stackView
    }()

    init() {
        self.userCoursesReviewsBlockAssembly = UserCoursesReviewsBlockAssembly()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.refreshSubmodules()
    }

    // MARK: Public API

    func refreshSubmodules() {
        self.userCoursesReviewsBlockAssembly.moduleInput?.refreshUserCoursesReviews()
    }

    // MARK: Private API

    private func setup() {
        self.view.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.stackViewInsets)
            make.height.equalTo(Appearance.stackViewHeight)
        }

        let userCoursesReviewsBlockViewController = self.userCoursesReviewsBlockAssembly.makeModule()

        self.addChild(userCoursesReviewsBlockViewController)
        self.stackView.addArrangedSubview(userCoursesReviewsBlockViewController.view)
        userCoursesReviewsBlockViewController.didMove(toParent: self)

        let wishlistView = UIView()
        self.stackView.addArrangedSubview(wishlistView)
    }
}
