import SnapKit
import UIKit

extension CourseInfoTabNewsBadgesView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 8
    }
}

final class CourseInfoTabNewsBadgesView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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

    func configure(viewModel: CourseInfoTabNewsBadgeViewModel) {
        self.stackView.removeAllArrangedSubviews()

        let statusBadgeType: CourseInfoTabNewsBadgeView.BadgeType = {
            switch viewModel.status {
            case .composing:
                return .composing
            case .scheduled:
                return viewModel.isActiveEvent ? .sending : .scheduled
            case .queueing, .queued, .sending:
                return .sending
            case .sent, .aborted:
                return .sent
            }
        }()
        let statusBadge = CourseInfoTabNewsBadgeView()
        statusBadge.configure(type: statusBadgeType)

        let eventTypeBadge = CourseInfoTabNewsBadgeView()
        eventTypeBadge.configure(type: viewModel.isOneTimeEvent ? .oneTime : .onEvent)

        self.stackView.addArrangedSubview(statusBadge)
        self.stackView.addArrangedSubview(eventTypeBadge)

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoTabNewsBadgesView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
