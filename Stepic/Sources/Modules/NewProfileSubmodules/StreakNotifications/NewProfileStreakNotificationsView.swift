import SnapKit
import UIKit

protocol NewProfileStreakNotificationsViewDelegate: AnyObject {
    func newProfileStreakNotificationsView(
        _ view: NewProfileStreakNotificationsView,
        didChangeStreakNotificationsPreference isOn: Bool
    )
    func newProfileStreakNotificationsViewDidTouchChangeNotificationsTime(
        _ view: NewProfileStreakNotificationsView
    )
}

extension NewProfileStreakNotificationsView {
    struct Appearance {
        let arrangedSubviewHeight: CGFloat = 44
        let backgroundColor = UIColor.clear
    }
}

final class NewProfileStreakNotificationsView: UIView {
    weak var delegate: NewProfileStreakNotificationsViewDelegate?

    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var streakNotificationsSwitchView: NewProfileStreakNotificationsSwitchView = {
        let view = NewProfileStreakNotificationsSwitchView()
        view.onSwitchValueChanged = { [weak self] isOn in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.newProfileStreakNotificationsView(
                strongSelf,
                didChangeStreakNotificationsPreference: isOn
            )
        }
        return view
    }()

    private lazy var streakNotificationsTimeSelectionView: NewProfileStreakNotificationsTimeSelectionView = {
        let view = NewProfileStreakNotificationsTimeSelectionView()
        view.addTarget(self, action: #selector(self.didTouchTimeSelection), for: .touchUpInside)
        return view
    }()

    private lazy var streakNotificationsFooterView = NewProfileStreakNotificationsFooterView()

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: stackViewIntrinsicContentSize.height
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.configure(
            viewModel: .init(
                isStreakNotificationsEnabled: false,
                formattedStreakNotificationsTime: nil,
                formattedStreakNotificationsUpdatingTime: nil
            )
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: NewProfileStreakNotificationsViewModel) {
        self.streakNotificationsSwitchView.isOn = viewModel.isStreakNotificationsEnabled
        self.streakNotificationsSwitchView.isSeparatorHidden = !viewModel.isStreakNotificationsEnabled

        self.streakNotificationsTimeSelectionView.detailText = viewModel.formattedStreakNotificationsTime
        self.streakNotificationsTimeSelectionView.isHidden = !viewModel.isStreakNotificationsEnabled

        self.streakNotificationsFooterView.text = viewModel.formattedStreakNotificationsUpdatingTime
        self.streakNotificationsFooterView.isHidden = !viewModel.isStreakNotificationsEnabled
    }

    @objc
    private func didTouchTimeSelection() {
        self.delegate?.newProfileStreakNotificationsViewDidTouchChangeNotificationsTime(self)
    }
}

extension NewProfileStreakNotificationsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.streakNotificationsSwitchView)
        self.stackView.addArrangedSubview(self.streakNotificationsTimeSelectionView)
        self.stackView.addArrangedSubview(self.streakNotificationsFooterView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.streakNotificationsSwitchView.translatesAutoresizingMaskIntoConstraints = false
        self.streakNotificationsSwitchView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.arrangedSubviewHeight)
        }

        self.streakNotificationsTimeSelectionView.translatesAutoresizingMaskIntoConstraints = false
        self.streakNotificationsTimeSelectionView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.arrangedSubviewHeight)
        }
    }
}
