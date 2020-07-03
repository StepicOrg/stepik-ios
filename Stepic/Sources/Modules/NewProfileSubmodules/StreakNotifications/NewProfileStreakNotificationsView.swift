import SnapKit
import UIKit

extension NewProfileStreakNotificationsView {
    struct Appearance {
        let arrangedSubviewHeight: CGFloat = 44
        let backgroundColor = UIColor.clear
    }
}

final class NewProfileStreakNotificationsView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var streakNotificationsSwitchView: NewProfileStreakNotificationsSwitchView = {
        let view = NewProfileStreakNotificationsSwitchView()
        view.onSwitchValueChanged = { isOn in
            print("SwitchValueChanged isOn=\(isOn)")
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

        self.streakNotificationsTimeSelectionView.subtitle = "8:00PM – 9:00 PM"
        self.streakNotificationsFooterView.text = "Рекорды обновляются в 3:00 AM"
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func didTouchTimeSelection() {
        print(#function)
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
