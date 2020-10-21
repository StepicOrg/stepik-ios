import SnapKit
import UIKit

extension TableQuizSelectColumnsView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
    }
}

final class TableQuizSelectColumnsView: UIView {
    let appearance: Appearance

    private lazy var columnsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private var columns = [TableQuiz.Column]()
    private var selectedColumnsIDs = Set<UniqueIdentifierType>()

    override var intrinsicContentSize: CGSize {
        let columnsStackViewIntrinsicContentSize = self.columnsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: columnsStackViewIntrinsicContentSize.height)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    func set(columns: [TableQuiz.Column], selectedColumnsIDs: Set<UniqueIdentifierType>) {
        if self.columns == columns {
            return
        }

        self.columns = columns
        self.selectedColumnsIDs = selectedColumnsIDs

        if !self.columnsStackView.arrangedSubviews.isEmpty {
            self.columnsStackView.removeAllArrangedSubviews()
        }

        for column in columns {
            let columnView = TableQuizSelectColumnsColumnView()

            self.columnsStackView.addArrangedSubview(columnView)

            columnView.setOn(self.selectedColumnsIDs.contains(column.uniqueIdentifier), animated: false)
            columnView.setTitle(column.text)
        }
    }
}

extension TableQuizSelectColumnsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.columnsStackView)
    }

    func makeConstraints() {
        self.columnsStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
