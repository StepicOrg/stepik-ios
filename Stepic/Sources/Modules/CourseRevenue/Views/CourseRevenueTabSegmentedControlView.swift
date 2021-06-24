import SnapKit
import UIKit

extension CourseRevenueTabSegmentedControlView {
    struct Appearance {
        let separatorBackgroundColor = UIColor.dynamic(
            light: .onSurface.withAlphaComponent(0.04),
            dark: .stepikSeparator
        )
        let separatorViewHeight: CGFloat = 1

        let insets = LayoutInsets.default
    }
}

final class CourseRevenueTabSegmentedControlView: UIView {
    let appearance: Appearance

    private let tabsTitles: [String]

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: self.tabsTitles)
        control.addTarget(self, action: #selector(self.onSegmentedControlValueChanged), for: .valueChanged)
        return control
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorBackgroundColor
        return view
    }()

    var selectedSegmentIndex: Int {
        get {
            self.segmentedControl.selectedSegmentIndex
        }
        set {
            self.segmentedControl.selectedSegmentIndex = newValue
        }
    }

    var segmentedControlValueDidChange: ((Int) -> Void)?

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.segmentedControl.intrinsicContentSize.height
                + self.appearance.insets.top
                + self.appearance.separatorViewHeight
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        tabsTitles: [String]
    ) {
        self.appearance = appearance
        self.tabsTitles = tabsTitles

        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onSegmentedControlValueChanged() {
        self.segmentedControlValueDidChange?(self.segmentedControl.selectedSegmentIndex)
    }
}

extension CourseRevenueTabSegmentedControlView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.segmentedControl)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(self.appearance.insets.left)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.insets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedControl.snp.bottom).offset(self.appearance.insets.top)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorViewHeight)
        }
    }
}
