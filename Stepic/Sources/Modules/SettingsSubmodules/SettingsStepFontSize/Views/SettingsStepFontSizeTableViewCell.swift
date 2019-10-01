import UIKit

final class SettingsStepFontSizeTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let textColor = UIColor.mainDark
        static let font = UIFont.systemFont(ofSize: 16)

        static let insets = LayoutInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private lazy var fontSizeTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.textColor
        label.font = Appearance.font
        label.numberOfLines = 1
        return label
    }()

    private lazy var cellView = UIView()

    // MARK: View life cycle

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.configure(viewModel: nil)
    }

    func configure(viewModel: SettingsStepFontSizeViewModel?) {
        self.fontSizeTextLabel.text = viewModel?.title
        self.accessoryType = (viewModel?.isSelected ?? false) ? .checkmark : .none
    }

    // MARK: - Private API

    private func setupSubview() {
        self.cellView.addSubview(self.fontSizeTextLabel)
        self.contentView.addSubview(self.cellView)

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.fontSizeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fontSizeTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.insets.left)
            make.top.equalToSuperview().offset(Appearance.insets.top)
            make.trailing.equalToSuperview().offset(-Appearance.insets.right)
            make.bottom.equalToSuperview().offset(-Appearance.insets.bottom)
        }
    }
}
