import SnapKit
import UIKit

extension ExploreCoursesCollectionHeaderView {
    struct Appearance {
        let summaryPlaceholderCornerRadius: CGFloat = 8
        let summaryPlaceholderHeight: CGFloat = 104
        let viewsSpacing: CGFloat = 20
    }
}

final class ExploreCoursesCollectionHeaderView: UIView, ExploreBlockHeaderViewProtocol {
    let appearance: Appearance
    private let color: GradientCoursesPlaceholderView.Color

    private lazy var headerView: ExploreBlockHeaderView = {
        let view = ExploreBlockHeaderView()
        view.onShowAllButtonClick = self.onShowAllButtonClick
        return view
    }()

    private lazy var summaryPlaceholder: GradientCoursesPlaceholderView = {
        let view = GradientCoursesPlaceholderViewFactory().makeCourseCollectionView(
            title: self.descriptionText,
            color: self.color
        )
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.summaryPlaceholderCornerRadius
        return view
    }()

    var titleText: String? {
        didSet {
            self.headerView.titleText = self.titleText
        }
    }

    var summaryText: String? {
        didSet {
            self.headerView.summaryText = self.summaryText
        }
    }

    private var descriptionText: String

    var onShowAllButtonClick: (() -> Void)? {
        didSet {
            self.headerView.onShowAllButtonClick = self.onShowAllButtonClick
        }
    }

    init(
        frame: CGRect = .zero,
        description: String,
        color: GradientCoursesPlaceholderView.Color,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.descriptionText = description
        self.color = color
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExploreCoursesCollectionHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.summaryPlaceholder)
        self.addSubview(self.headerView)
    }

    func makeConstraints() {
        self.summaryPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        self.summaryPlaceholder.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.summaryPlaceholderHeight)
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top
                .equalTo(self.summaryPlaceholder.snp.bottom)
                .offset(self.appearance.viewsSpacing)
        }
    }
}
