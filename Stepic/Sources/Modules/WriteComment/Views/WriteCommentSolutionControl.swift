import SnapKit
import UIKit

extension WriteCommentSolutionControl {
    struct Appearance {
        let textColor = UIColor.stepikAccent
        let textFont = UIFont.systemFont(ofSize: 17)

        let rightArrowImageSize = CGSize(width: 15, height: 15)
        let rightArrowImageInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
}

final class WriteCommentSolutionControl: UIControl {
    let appearance: Appearance

    private lazy var solutionControl: DiscussionsSolutionControl = {
        let control = DiscussionsSolutionControl(appearance: .init(isBorderEnabled: false))
        control.isUserInteractionEnabled = false
        return control
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textColor
        label.font = self.appearance.textFont
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var solutionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.solutionControl, self.titleLabel])
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var rightArrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "menu_arrow_right"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    override var isHighlighted: Bool {
        didSet {
            self.subviews.forEach { $0.alpha = self.isHighlighted ? 0.5 : 1.0 }
        }
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

    func configure(viewModel: ViewModel) {
        if viewModel.isSelected {
            self.solutionControl.isHidden = false
            self.titleLabel.isHidden = true

            self.solutionControl.update(state: viewModel.isCorrect ? .correct : .wrong, title: viewModel.title)
            self.titleLabel.text = nil
        } else {
            self.solutionControl.isHidden = true
            self.titleLabel.isHidden = false

            self.solutionControl.update(state: .wrong, title: nil)
            self.titleLabel.text = viewModel.title
        }
    }

    struct ViewModel {
        let title: String?
        let isCorrect: Bool
        let isSelected: Bool
    }
}

extension WriteCommentSolutionControl: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.solutionStackView)
        self.addSubview(self.rightArrowImageView)
    }

    func makeConstraints() {
        self.solutionStackView.translatesAutoresizingMaskIntoConstraints = false
        self.solutionStackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        self.rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        self.rightArrowImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.solutionStackView.snp.trailing).offset(self.appearance.rightArrowImageInsets.left)
            make.trailing.equalToSuperview()
            make.size.equalTo(self.appearance.rightArrowImageSize)
            make.centerY.equalToSuperview()
        }
    }
}
