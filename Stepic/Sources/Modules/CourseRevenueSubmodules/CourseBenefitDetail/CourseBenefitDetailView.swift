import SnapKit
import UIKit

protocol CourseBenefitDetailViewDelegate: AnyObject {
    func courseBenefitDetailViewDidClickCloseButton(_ view: CourseBenefitDetailView)
}

extension CourseBenefitDetailView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)
    }
}

final class CourseBenefitDetailView: UIView {
    let appearance: Appearance

    weak var delegate: CourseBenefitDetailViewDelegate?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        return scrollableStackView
    }()

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
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

    func showLoading() {
        self.scrollableStackView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func configure(viewModel: CourseBenefitDetailViewModel) {
        print("CourseBenefitDetailViewModel = \(viewModel)")
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.courseBenefitDetailViewDidClickCloseButton(self)
    }
}

extension CourseBenefitDetailView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.closeButton)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.closeButtonWidthHeight)
            make.top.equalToSuperview().offset(self.appearance.closeButtonInsets.top)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.closeButtonInsets.right)
        }
    }
}

extension CourseBenefitDetailView: PanModalScrollable {
    var panScrollable: UIScrollView? {
        self.loadingIndicator.isAnimating ? nil : self.scrollableStackView.panScrollable
    }
}
