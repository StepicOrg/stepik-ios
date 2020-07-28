import SnapKit
import UIKit

protocol NewProfileSocialProfilesViewDelegate: AnyObject {
    func newProfileSocialProfilesView(_ view: NewProfileSocialProfilesView, didOpenExternalLink url: URL)
}

extension NewProfileSocialProfilesView {
    struct Appearance {
        let itemHeight: CGFloat = 44

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileSocialProfilesView: UIView {
    let appearance: Appearance

    weak var delegate: NewProfileSocialProfilesViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showLoading() {
        self.skeleton.viewBuilder = {
            NewProfileSocialProfilesSkeletonView()
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }

    func configure(viewModel: NewProfileSocialProfilesViewModel) {
        for subview in self.stackView.subviews {
            self.stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for (idx, socialProfile) in viewModel.socialProfiles.enumerated() {
            let itemView = NewProfileSocialProfilesItemView()
            itemView.image = UIImage(named: socialProfile.iconName)
            itemView.text = socialProfile.title
            itemView.link = socialProfile.url
            itemView.isSeparatorHidden = idx == (viewModel.socialProfiles.count - 1)
            itemView.addTarget(self, action: #selector(self.socialProfilesViewTouched(_:)), for: .touchUpInside)

            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.itemHeight)
            }

            self.stackView.addArrangedSubview(itemView)
        }
    }

    @objc
    private func socialProfilesViewTouched(_ view: NewProfileSocialProfilesItemView) {
        if let link = view.link {
            self.delegate?.newProfileSocialProfilesView(self, didOpenExternalLink: link)
        }
    }
}

extension NewProfileSocialProfilesView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
