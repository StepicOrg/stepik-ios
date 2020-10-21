import SnapKit
import UIKit

protocol TableQuizViewDelegate: AnyObject {
    func tableQuizView(_ view: TableQuizView, didSelectRow row: TableQuiz.Row)
}

extension TableQuizView {
    struct Appearance {
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let titleTextColor = UIColor.stepikPrimaryText
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

        let separatorColor = UIColor.stepikSeparator
        let separatorHeight: CGFloat = 0.5
    }
}

final class TableQuizView: UIView {
    let appearance: Appearance

    weak var delegate: TableQuizViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        return label
    }()
    private lazy var titleLabelContainerView = UIView()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var rowsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private var rows = [TableQuiz.Row]()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var isEnabled = true {
        didSet {
            self.rowsStackView.isUserInteractionEnabled = self.isEnabled
            for arrangedSubview in self.rowsStackView.arrangedSubviews {
                if let rowView = arrangedSubview as? TableRowView {
                    rowView.isEnabled = self.isEnabled
                }
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentStackViewIntrinsicContentSize = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: contentStackViewIntrinsicContentSize.height)
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

    func set(rows: [TableQuiz.Row]) {
        if self.rows == rows {
            return
        }

        self.rows = rows

        if !self.rowsStackView.arrangedSubviews.isEmpty {
            self.rowsStackView.removeAllArrangedSubviews()
        }

        for row in rows {
            let rowView = TableRowView()
            rowView.onClick = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.delegate?.tableQuizView(strongSelf, didSelectRow: row)
            }
            rowView.tag = row.uniqueIdentifier.hashValue

            self.rowsStackView.addArrangedSubview(rowView)

            rowView.title = row.text
            rowView.subtitle = self.makeFormattedSubtitleText(row: row)
        }
    }

    func updateRowAnswers(row: TableQuiz.Row) {
        if let rowIndex = self.rows.firstIndex(where: { $0.uniqueIdentifier == row.uniqueIdentifier }) {
            self.rows[rowIndex] = row
        }

        for arrangedSubview in self.rowsStackView.arrangedSubviews {
            guard let rowView = arrangedSubview as? TableRowView else {
                continue
            }

            if rowView.tag == row.uniqueIdentifier.hashValue {
                rowView.subtitle = self.makeFormattedSubtitleText(row: row)
            }
        }
    }

    private func makeFormattedSubtitleText(row: TableQuiz.Row) -> String {
        row.answers.map(\.text).joined(separator: ", ")
    }
}

extension TableQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
    }

    func addSubviews() {
        self.addSubview(self.contentStackView)

        self.contentStackView.addArrangedSubview(self.titleLabelContainerView)
        self.titleLabelContainerView.addSubview(self.titleLabel)

        self.contentStackView.addArrangedSubview(self.separatorView)
        self.contentStackView.addArrangedSubview(self.rowsStackView)
    }

    func makeConstraints() {
        self.contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.titleLabelInsets)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
