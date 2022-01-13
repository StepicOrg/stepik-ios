import SnapKit
import UIKit

extension CourseRevenueTabMonthlyCellView {
    struct Appearance {
        let totalViewInsets = LayoutInsets.default

        let itemsStackViewSpacing: CGFloat = 16
        let itemsStackViewInsets = LayoutInsets(top: 16, left: 32, bottom: 16, right: 32)
    }
}

final class CourseRevenueTabMonthlyCellView: UIView {
    let appearance: Appearance

    private lazy var totalView = CourseRevenueTabMonthlyTotalView()

    private lazy var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.itemsStackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let itemsStackViewHeight = self.itemsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height

        let height = self.appearance.totalViewInsets.top
            + self.totalView.intrinsicContentSize.height
            + self.appearance.itemsStackViewInsets.top
            + itemsStackViewHeight
            + self.appearance.itemsStackViewInsets.bottom

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseRevenueTabMonthlyViewModel?) {
        self.totalView.title = viewModel?.formattedDate
        self.totalView.style = (viewModel?.totalIncome ?? 0) < (viewModel?.totalRefunds ?? 0) ? .red : .yellowGreen
        if let formattedTotalIncome = viewModel?.formattedTotalIncome {
            self.totalView.rightDetailAttributedTitle = FormatterHelper.priceCourseRevenueToAttributedString(
                price: formattedTotalIncome,
                priceFont: self.totalView.appearance.titleFont,
                priceColor: self.totalView.rightDetailTitleLabelTextColor
            )
        } else {
            self.totalView.rightDetailAttributedTitle = nil
        }


        self.itemsStackView.removeAllArrangedSubviews()
        let itemViewAppearance = CourseRevenueTabMonthlyItemView.Appearance()

        let items: [Item] = [
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyTurnoverTitle", comment: ""),
                attributedSubtitle: FormatterHelper.priceCourseRevenueToAttributedString(
                    price: viewModel?.formattedTotalTurnover ?? "",
                    priceFont: itemViewAppearance.titleFont,
                    priceColor: itemViewAppearance.titleTextColor
                )
            ),
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyRefundsTitle", comment: ""),
                attributedSubtitle: FormatterHelper.priceCourseRevenueToAttributedString(
                    price: viewModel?.formattedTotalRefunds ?? "",
                    priceFont: itemViewAppearance.titleFont,
                    priceColor: itemViewAppearance.titleTextColor
                )
            ),
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyIncomeTitle", comment: ""),
                subtitle: "\(viewModel?.countPayments ?? 0)"
            ),
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyChannelStepikTitle", comment: ""),
                subtitle: "\(viewModel?.countNonZPayments ?? 0)",
                image: UIImage(named: "course-revenue-transaction-logo")?.withRenderingMode(.alwaysOriginal)
            ),
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyChannelZLinkTitle", comment: ""),
                subtitle: "\(viewModel?.countZPayments ?? 0)",
                image: UIImage(named: "course-revenue-transaction-z-link")?.withRenderingMode(.alwaysOriginal)
            ),
            Item(
                title: NSLocalizedString("CourseRevenueTabMonthlyChannelInvoicePaymentsTitle", comment: ""),
                subtitle: "\(viewModel?.countInvoicePayments ?? 0)",
                image: UIImage(named: "course-revenue-transaction-logo")?.withRenderingMode(.alwaysTemplate)
            )
        ]
        items.forEach { item in
            let view = CourseRevenueTabMonthlyItemView(shouldShowImageView: item.image != nil)
            view.title = item.title

            if let attributedSubtitle = item.attributedSubtitle {
                view.rightDetailAttributedTitle = attributedSubtitle
            } else {
                view.rightDetailTitle = item.subtitle
            }

            if let image = item.image {
                view.image = image
            }

            self.itemsStackView.addArrangedSubview(view)
        }

        self.invalidateIntrinsicContentSize()
    }

    private struct Item {
        var title: String?
        var subtitle: String?
        var attributedSubtitle: NSAttributedString?
        var image: UIImage?
    }
}

extension CourseRevenueTabMonthlyCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.totalView)
        self.addSubview(self.itemsStackView)
    }

    func makeConstraints() {
        self.totalView.translatesAutoresizingMaskIntoConstraints = false
        self.totalView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.totalViewInsets.edgeInsets)
        }

        self.itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.totalView.snp.bottom).offset(self.appearance.itemsStackViewInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.itemsStackViewInsets.edgeInsets)
        }
    }
}
