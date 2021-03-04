import SnapKit
import UIKit

protocol NewProfileBlockHeaderViewProtocol: AnyObject {
    var titleText: String? { get set }
    var onShowAllButtonClick: (() -> Void)? { get set }
}

extension NewProfileBlockHeaderView {
    struct Appearance {
        let titleLabelColor = UIColor.stepikSystemPrimaryText
        let titleLabelFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        let showAllButtonInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
}

final class NewProfileBlockHeaderView: UIControl, NewProfileBlockHeaderViewProtocol {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var showAllButton: ShowAllButton = {
        let button = ShowAllButton()
        button.title = nil
        button.addTarget(self, action: #selector(self.showAllButtonClicked), for: .touchUpInside)
        return button
    }()

    var titleText: String? {
        didSet {
            self.titleLabel.isHidden = self.titleText == nil
            self.titleLabel.text = self.titleText
        }
    }

    var isShowAllButtonHidden = false {
        didSet {
            self.showAllButton.isHidden = self.isShowAllButtonHidden
        }
    }

    var onShowAllButtonClick: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.showAllButton.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let showAllButtonHeight = self.isShowAllButtonHidden ? 0 : self.showAllButton.intrinsicContentSize.height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.titleLabel.intrinsicContentSize.height, showAllButtonHeight)
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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func showAllButtonClicked() {
        self.onShowAllButtonClick?()
    }
}

extension NewProfileBlockHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.addTarget(self, action: #selector(self.showAllButtonClicked), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.showAllButton)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.showAllButton.snp.makeConstraints { make in
            make.leading
                .equalTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.showAllButtonInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
    }
}
