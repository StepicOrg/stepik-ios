import SnapKit
import UIKit

extension StepQuizReviewExpandQuizView {
    struct Appearance {
        let primaryColor = UIColor.stepikPrimaryText
        let backgroundColor = UIColor.onSurface.withAlphaComponent(0.04)

        let titleFont = Typography.bodyFont
        let titleInsets = LayoutInsets.default

        let expandContentControlSize = CGSize(width: 16, height: 16)
        let expandContentControlInsets = LayoutInsets(right: 16)
    }
}

final class StepQuizReviewExpandQuizView: UIView {
    let appearance: Appearance

    private lazy var separatorView = SeparatorView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.primaryColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var expandContentControl: ExpandContentControl = {
        let control = ExpandContentControl()
        control.onClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.isExpanded.toggle()
            strongSelf.onExpand?(strongSelf.isExpanded)
        }
        return control
    }()
    private lazy var expandContentTapProxyView = TapProxyView(targetView: self.expandContentControl)

    private var isExpanded = false

    var onExpand: ((Bool) -> Void)?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.titleInsets.top
            + self.titleLabel.intrinsicContentSize.height
            + self.appearance.titleInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.expandContentTapProxyView)
        return self.expandContentTapProxyView.hitTest(convertedPoint, with: event)
    }
}

extension StepQuizReviewExpandQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.separatorView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.expandContentControl)
        self.addSubview(self.expandContentTapProxyView)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(self.appearance.titleInsets.edgeInsets)
        }

        self.expandContentControl.translatesAutoresizingMaskIntoConstraints = false
        self.expandContentControl.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.expandContentControlSize)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.expandContentControlInsets.right)
        }

        self.expandContentTapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.expandContentTapProxyView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
