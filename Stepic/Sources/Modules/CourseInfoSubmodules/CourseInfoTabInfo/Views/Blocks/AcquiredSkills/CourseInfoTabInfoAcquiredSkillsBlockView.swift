import SnapKit
import UIKit

extension CourseInfoTabInfoAcquiredSkillsBlockView {
    struct Appearance {
        var titleLabelAppearance = CourseInfoTabInfoLabel.Appearance(
            maxLinesCount: 1,
            font: Typography.headlineFont,
            textColor: UIColor.stepikMaterialPrimaryText
        )
        var titleLabelInsets = LayoutInsets(left: 16, right: 16)

        let stackViewSpacing: CGFloat = 20
        var stackViewInsets = LayoutInsets(top: 20, left: 16, right: 16)
    }
}

final class CourseInfoTabInfoAcquiredSkillsBlockView: UIView {
    let appearance: Appearance

    private lazy var titleLabel = CourseInfoTabInfoLabel(appearance: self.appearance.titleLabelAppearance)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = self.titleLabel.intrinsicContentSize.height
            + self.appearance.stackViewInsets.top
            + stackViewIntrinsicContentSize.height
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

    func configure(acquiredSkills: [String]) {
        defer {
            self.invalidateIntrinsicContentSize()
        }

        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
        }

        if acquiredSkills.isEmpty {
            return
        }

        for acquiredSkill in acquiredSkills {
            let acquiredSkillView = CourseInfoTabInfoAcquiredSkillView()
            acquiredSkillView.title = acquiredSkill
            self.stackView.addArrangedSubview(acquiredSkillView)
        }
    }
}

extension CourseInfoTabInfoAcquiredSkillsBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.titleLabelInsets.edgeInsets)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.stackViewInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }
    }
}
