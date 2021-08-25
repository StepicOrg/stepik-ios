import SnapKit
import UIKit

extension StepQuizReviewStatusCircleView {
    struct Appearance {
        var borderColor: UIColor?
        let borderWidth: CGFloat = 2.5

        var backgroundColor = UIColor.stepikBackground

        var imageViewSize = CGSize.zero
        let imageViewTintColor = UIColor.white

        let textFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        var textColor = UIColor.stepikMaterialPrimaryText
    }
}

final class StepQuizReviewStatusCircleView: UIView {
    var appearance: Appearance {
        didSet {
            self.updateAppearance()
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    var image: UIImage? {
        get {
            self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }

    var text: String? {
        get {
            self.textLabel.text
        }
        set {
            self.textLabel.text = newValue
        }
    }

    var imageViewIsHidden: Bool {
        get {
            self.imageView.isHidden
        }
        set {
            self.imageView.isHidden = newValue
        }
    }

    var textLabelIsHidden: Bool {
        get {
            self.textLabel.isHidden
        }
        set {
            self.textLabel.isHidden = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let imageViewHeight = self.imageView.isHidden ? 0 : self.imageView.intrinsicContentSize.height
        let textLabelHeight = self.textLabel.isHidden ? 0 : self.textLabel.intrinsicContentSize.height
        let height = max(imageViewHeight, textLabelHeight)
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

        self.updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateAppearance()
        }
    }

    private func updateAppearance() {
        self.layer.borderColor = self.appearance.borderColor?.cgColor
        self.layer.borderWidth = self.layer.borderColor != nil ? self.appearance.borderWidth : 0

        self.backgroundColor = self.appearance.backgroundColor

        self.imageView.tintColor = self.appearance.imageViewTintColor

        self.textLabel.font = self.appearance.textFont
        self.textLabel.textColor = self.appearance.textColor
    }
}

extension StepQuizReviewStatusCircleView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageViewSize)
            make.center.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
