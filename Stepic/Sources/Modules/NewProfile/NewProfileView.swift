import SnapKit
import UIKit

extension NewProfileView {
    struct Appearance {
        let backgroundColor = UIColor.stepikGroupedBackground
    }
}

final class NewProfileView: UIView {
    let appearance: Appearance

    private lazy var scrollableStackView = ScrollableStackView(orientation: .vertical)

    private lazy var headerView = NewProfileHeaderView()

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

    func showLoading() {}

    func hideLoading() {}

    func configure(viewModel: NewProfileViewModel) {
        self.headerView.configure(viewModel: viewModel.headerViewModel)
    }

    // MARK: Blocks

    func addBlockView(_ view: UIView) {
        self.scrollableStackView.addArrangedView(view)
    }

    func removeBlockView(_ view: UIView) {
        self.scrollableStackView.removeArrangedView(view)
    }

    func insertBlockView(_ view: UIView, at position: Int) {
        self.scrollableStackView.insertArrangedView(view, at: position)
    }

    func insertBlockView(_ view: UIView, before previousView: UIView) {
        for (index, subview) in self.scrollableStackView.arrangedSubviews.enumerated() where subview === previousView {
            self.scrollableStackView.insertArrangedView(view, at: index)
            return
        }
        self.scrollableStackView.addArrangedView(view)
    }
}

extension NewProfileView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)

        self.scrollableStackView.addArrangedView(self.headerView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
