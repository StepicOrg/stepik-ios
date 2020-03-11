import SnapKit
import UIKit

extension DiscussionsLoadMoreTableViewCell {
    enum Appearance {
        static let containerHeight: CGFloat = 52
        static let containerBackgroundColor = UIColor(hex6: 0xF6F6F6)

        static let titleLabelFont = UIFont.systemFont(ofSize: 14)
        static let titleLabelTextColor = UIColor.mainDark

        static let separatorHeight: CGFloat = 0.5
        static let separatorColor = UIColor(hex6: 0xe7e7e7)
    }
}

final class DiscussionsLoadMoreTableViewCell: UITableViewCell, Reusable {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.titleLabelFont
        label.textColor = Appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.containerBackgroundColor
        return view
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var isUpdating: Bool = false {
        didSet {
            if self.isUpdating {
                self.titleLabel.isHidden = true
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
                self.titleLabel.isHidden = false
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.isHidden = false
    }

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.containerView.superview == nil {
            self.setupSubview()
        }
    }

    private func setupSubview() {
        self.contentView.addSubview(self.containerView)
        self.contentView.addSubview(self.separatorView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.activityIndicatorView)

        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Appearance.containerHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(Appearance.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.top.equalTo(self.containerView.snp.bottom)
        }
    }
}
