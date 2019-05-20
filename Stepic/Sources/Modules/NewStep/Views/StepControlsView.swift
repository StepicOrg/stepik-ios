import SnapKit
import UIKit

extension StepControlsView {
    struct Appearance {
        let navigationButtonsSpacing: CGFloat = 16
        let navigationButtonsInset = LayoutInsets(left: 16, right: 16)
        let navigationButtonsHeight: CGFloat = 44
    }
}

final class StepControlsView: UIView {
    let appearance: Appearance

    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        return submitButton
    }()

    private lazy var navigationPreviousButton = StepNavigationButton(type: .previous, isCentered: false)
    private lazy var navigationNextButton = StepNavigationButton(type: .next, isCentered: true)

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.navigationPreviousButton])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.navigationButtonsSpacing
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.navigationButtonsHeight
        )
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension StepControlsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.navigationStackView)
    }

    func makeConstraints() {
        self.navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.navigationButtonsInset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.navigationButtonsInset.right)
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }
    }
}
