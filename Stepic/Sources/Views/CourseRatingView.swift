import Nuke
import SnapKit
import UIKit

extension CourseRatingView {
    struct Appearance {
        var starFilledColor = UIColor(hex: 0x66cc66)
        var statClearColor = UIColor.white

        let starsSpacing: CGFloat = 5.0
        let starsSize = CGSize(width: 10.5, height: 10.5)
    }
}

final class CourseRatingView: UIView {
    let appearance: Appearance
    private static let maxStarsCount = 5

    private lazy var starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.starsSpacing
        return stackView
    }()

    var starsCount: Int = 0 {
        didSet {
            self.updateStars(count: self.starsCount)
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateStars(count: Int) {
        self.starsStackView.removeAllArrangedSubviews()
        let count = min(CourseRatingView.maxStarsCount, count)

        for _ in 0..<count {
            self.starsStackView.addArrangedSubview(self.makeStar(isFilled: true))
        }

        for _ in 0..<(CourseRatingView.maxStarsCount - count) {
            self.starsStackView.addArrangedSubview(self.makeStar(isFilled: false))
        }
    }

    private func makeStar(isFilled: Bool) -> UIView {
        let image = isFilled
            ? UIImage(named: "rating-star-filled")
            : UIImage(named: "rating-star-clear")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = isFilled ? self.appearance.starFilledColor : self.appearance.statClearColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.starsSize)
        }
        return imageView
    }
}

extension CourseRatingView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateStars(count: self.starsCount)
    }

    func addSubviews() {
        self.addSubview(self.starsStackView)
    }

    func makeConstraints() {
        self.starsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.starsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
