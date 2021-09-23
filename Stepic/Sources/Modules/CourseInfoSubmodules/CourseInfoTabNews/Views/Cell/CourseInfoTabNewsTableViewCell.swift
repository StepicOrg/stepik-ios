import UIKit

extension CourseInfoTabNewsTableViewCell {
    enum Appearance {
        static let separatorHeight: CGFloat = 4
        static let separatorColor = UIColor.onSurface.withAlphaComponent(0.04)
    }
}

final class CourseInfoTabNewsTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView: CourseInfoTabNewsCellView = {
        let cellView = CourseInfoTabNewsCellView()
        cellView.onNewHeightUpdate = { [weak self] in
            guard let strongSelf = self else {
                return
            }


            let fittingSize = CGSize(width: strongSelf.cellView.bounds.width, height: .infinity)
            let cellSize = strongSelf.sizeThatFits(fittingSize)

            strongSelf.onNewHeightUpdate?(cellSize.height)
        }
        return cellView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    var onContentLoaded: (() -> Void)? {
        get {
            self.cellView.onContentLoaded
        }
        set {
            self.cellView.onContentLoaded = newValue
        }
    }
    var onNewHeightUpdate: ((CGFloat) -> Void)?

    var onImageClick: ((URL) -> Void)? {
        get {
            self.cellView.onImageClick
        }
        set {
            self.cellView.onImageClick = newValue
        }
    }
    var onLinkClick: ((URL) -> Void)? {
        get {
            self.cellView.onLinkClick
        }
        set {
            self.cellView.onLinkClick = newValue
        }
    }

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellView.configure(viewModel: nil)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let cellViewSize = self.cellView.sizeThatFits(size)
        return CGSize(width: cellViewSize.width, height: cellViewSize.height + Appearance.separatorHeight)
    }

    func configure(viewModel: CourseInfoTabNewsViewModel) {
        self.cellView.configure(viewModel: viewModel)
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.cellView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.height.equalTo(Appearance.separatorHeight)
        }
    }
}
