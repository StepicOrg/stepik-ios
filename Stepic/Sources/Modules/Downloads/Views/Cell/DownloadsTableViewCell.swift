import SnapKit
import UIKit

final class DownloadsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let cellViewInsets = LayoutInsets(top: 8, left: 16, bottom: 8, right: 16)

        static let separatorHeight: CGFloat = 0.5
        static let separatorColor = UIColor(hex6: 0xe7e7e7)
        static let separatorInsets = LayoutInsets(left: 16)
    }

    private lazy var cellView = DownloadsCellView()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.cellView.coverImageURL = nil
        self.cellView.shouldShowAdaptiveMark = false
        self.cellView.title = nil
        self.cellView.subtitle = nil
    }

    func configure(viewModel: DownloadsItemViewModel) {
        self.cellView.coverImageURL = viewModel.coverImageURL
        self.cellView.shouldShowAdaptiveMark = viewModel.isAdaptive
        self.cellView.title = viewModel.title
        self.cellView.subtitle = viewModel.subtitle
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.cellViewInsets.left)
            make.top.equalToSuperview().offset(Appearance.cellViewInsets.top)
            make.trailing.equalToSuperview().offset(-Appearance.cellViewInsets.right)
            make.bottom.equalToSuperview().offset(-Appearance.cellViewInsets.bottom)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.separatorInsets.left)
            make.height.equalTo(Appearance.separatorHeight)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
        }
    }
}
