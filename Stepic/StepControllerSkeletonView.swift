import UIKit
import SnapKit

extension StepControllerSkeletonView {
    struct Appearance {
        let imageViewInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 0)
        let imageViewCornerRadius: CGFloat = 5

        let titleLabelHeight: CGFloat = 17
        let titleLabelCornerRadius: CGFloat = 5
        let titleLabelInsets = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 16)
        let rightStackViewInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 16)
        let rightStackViewSpacing: CGFloat = 8

        let labelHeight: CGFloat = 15
        let labelCornerRadius: CGFloat = 5
    }
}

final class StepControllerSkeletonView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.imageViewCornerRadius
        return view
    }()

    private lazy var titleLabelView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.titleLabelCornerRadius
        return view
    }()

    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.makeLabelView(), self.makeLabelView()])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.rightStackViewSpacing
        return stackView
    }()

    private lazy var bottomLabelView = self.makeLabelView()
    private lazy var bottomShortLabelView = self.makeLabelView()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeLabelView() -> UIView {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.labelCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.labelHeight)
        }
        return view
    }
}

extension StepControllerSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabelView)
        self.addSubview(self.rightStackView)
        self.addSubview(self.bottomLabelView)
        self.addSubview(self.bottomShortLabelView)
    }

    func makeConstraints() {
        self.titleLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.titleLabelHeight)
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabelView.snp.bottom).offset(self.appearance.imageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.imageViewInsets.left)
            make.width.equalToSuperview().multipliedBy(0.4).priority(.high)
            make.height.equalTo(self.imageView.snp.width).multipliedBy(0.6).priority(.medium)
        }

        self.rightStackView.translatesAutoresizingMaskIntoConstraints = false
        self.rightStackView.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.top).offset(2)
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.rightStackViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.rightStackViewInsets.right)
        }

        self.bottomLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLabelView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.imageViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.rightStackViewInsets.right)
            make.top.equalTo(self.imageView.snp.bottom).offset(self.appearance.imageViewInsets.top)
        }

        self.bottomShortLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomShortLabelView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.imageViewInsets.left)
            make.width.equalTo(self.bottomLabelView.snp.width).multipliedBy(0.85)
            make.top.equalTo(self.bottomLabelView.snp.bottom).offset(self.appearance.rightStackViewSpacing)
        }
    }
}
