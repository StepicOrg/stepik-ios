import SnapKit
import UIKit

protocol CodeLanguagePickerViewDelegate: class {
    func codeLanguagePickerView(_ view: CodeLanguagePickerView, didSelectLanguage language: String)
}

extension CodeLanguagePickerView {
    struct Appearance {
        let insets = LayoutInsets(left: 16, right: 16)
        let iconSize = CGSize(width: 16, height: 16)
        let horizontalSpacing: CGFloat = 16
        let headerHeight: CGFloat = 44

        let tableViewHeight: CGFloat = 192
        let tableViewEstimatedRowHeight: CGFloat = 44
        let separatorStyle = UITableViewCell.SeparatorStyle.singleLine

        let mainColor = UIColor.mainDark
        let titleTextFont = UIFont.systemFont(ofSize: 16)
        let emptyTextFont = UIFont.systemFont(ofSize: 16)
        let emptyTextColor = UIColor.lightGray
    }
}

final class CodeLanguagePickerView: UIView {
    private static let cellReuseIdentifier = "CodeLanguageCell"

    let appearance: Appearance
    weak var delegate: CodeLanguagePickerViewDelegate?

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-select-language")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleTextFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var headerContainerView = UIView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = self.appearance.tableViewEstimatedRowHeight
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CodeLanguagePickerView.cellReuseIdentifier)

        return tableView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                SeparatorView(),
                self.headerContainerView,
                SeparatorView(),
                self.tableView,
                SeparatorView()
            ]
        )
        stackView.axis = .vertical
        return stackView
    }()

    var onLanguageSelect: (() -> Void)?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var languages: [String] = [] {
        didSet {
            self.tableView.reloadData()
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
}

extension CodeLanguagePickerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.title = NSLocalizedString("SelectLanguage", comment: "")
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.headerContainerView.addSubview(self.iconImageView)
        self.headerContainerView.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerHeight)
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.iconSize.width)
            make.height.equalTo(self.appearance.iconSize.height)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.tableViewHeight)
        }
    }
}

extension CodeLanguagePickerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.languages.isEmpty {
            self.displayEmptyView()
        } else {
            self.hideEmptyView()
        }

        return self.languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CodeLanguagePickerView.cellReuseIdentifier,
            for: indexPath
        )
        cell.textLabel?.text = self.languages[indexPath.row]
        cell.textLabel?.textColor = self.appearance.mainColor

        return cell
    }

    private func displayEmptyView() {
        let messageLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: tableView.bounds.size))
        messageLabel.text = NSLocalizedString("CodeQuizEmptyCodeLanguages", comment: "")
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = self.appearance.emptyTextFont
        messageLabel.textColor = self.appearance.emptyTextColor
        messageLabel.sizeToFit()

        self.tableView.backgroundView = messageLabel
        self.tableView.separatorStyle = .none
    }

    private func hideEmptyView() {
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = self.appearance.separatorStyle
    }
}

extension CodeLanguagePickerView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.codeLanguagePickerView(self, didSelectLanguage: self.languages[indexPath.row])
    }
}
