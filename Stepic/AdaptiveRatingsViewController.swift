//
//  AdaptiveRatingsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.01.2018.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class AdaptiveRatingsViewController: UIViewController {
    enum State {
        case empty(message: String)
        case error(message: String)
        case loading
        case normal(message: String?)
    }

    private var state: State = .loading {
        didSet {
            switch self.state {
            case .loading:
                self.data = nil
                self.tableView.reloadData()
                self.loadingIndicator.startAnimating()
                self.allCountLabel.isHidden = true
            case .empty(let message), .error(let message):
                self.loadingIndicator.stopAnimating()
                self.allCountLabel.text = message
                self.allCountLabel.isHidden = false
            case .normal(let message):
                self.loadingIndicator.stopAnimating()
                self.tableView.reloadData()
                if let message = message {
                    self.allCountLabel.text = message
                    self.allCountLabel.isHidden = false
                } else {
                    self.allCountLabel.isHidden = true
                }
            }
        }
    }

    var presenter: AdaptiveRatingsPresenter?
    var daysCount: Int? = 1

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allCountLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!

    private var data: [Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.colorize()
        self.localize()

        self.setUpTable()
        self.presenter?.reloadData(days: daysCount, force: true)

        self.state = .loading

        self.presenter?.sendOpenedAnalytics()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = tableView.tableHeaderView else {
            return
        }

        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            self.tableView.tableHeaderView = headerView
            self.tableView.layoutIfNeeded()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    @IBAction
    func onRatingSegmentedControlValueChanged(_ sender: Any) {
        let sections: [Int: Int?] = [
            0: nil,
            1: 7,
            2: 1
        ]

        self.daysCount = sections[self.ratingSegmentedControl.selectedSegmentIndex] ?? 1
        self.state = .loading
        self.presenter?.reloadData(days: self.daysCount, force: false)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikBackground
        self.loadingIndicator.color = .stepikLoadingIndicator
        self.ratingSegmentedControl.tintColor = .stepikAccent
        self.allCountLabel.textColor = .stepikGray2
    }

    private func localize() {
        self.ratingSegmentedControl.setTitle(NSLocalizedString("AdaptiveAllTime", comment: ""), forSegmentAt: 0)
        self.ratingSegmentedControl.setTitle(NSLocalizedString("Adaptive7Days", comment: ""), forSegmentAt: 1)
        self.ratingSegmentedControl.setTitle(NSLocalizedString("AdaptiveToday", comment: ""), forSegmentAt: 2)
    }

    private func setUpTable() {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 112

        self.tableView.register(
            UINib(nibName: "LeaderboardTableViewCell", bundle: nil),
            forCellReuseIdentifier: LeaderboardTableViewCell.reuseId
        )

        self.tableView.contentInsetAdjustmentBehavior = .never
    }
}

extension AdaptiveRatingsViewController: AdaptiveRatingsView {
    private var separatorPosition: Int? {
        guard let data = self.data as? [RatingViewData] else {
            return nil
        }

        for i in 0..<max(0, data.count - 1) {
            if data[i].position + 1 != data[i + 1].position {
                return i
            }
        }

        return nil
    }

    func reload() {
        if self.data == nil {
            self.state = .empty(message: NSLocalizedString("AdaptiveProgressWeeksEmpty", comment: ""))
        } else {
            switch self.state {
            case .normal(let message):
                self.state = .normal(message: message)
            default:
                self.state = .normal(message: nil)
            }
        }
    }

    func setRatings(data: ScoreboardViewData) {
        self.data = data.leaders

        let pluralizedString = StringHelper.pluralize(number: data.allCount, forms: [
            NSLocalizedString("AdaptiveRatingFooterText1", comment: ""),
            NSLocalizedString("AdaptiveRatingFooterText234", comment: ""),
            NSLocalizedString("AdaptiveRatingFooterText567890", comment: "")
        ])
        self.state = .normal(message: String(format: pluralizedString, "\(data.allCount)"))
    }

    func showError() {
        self.state = .error(message: NSLocalizedString("AdaptiveRatingLoadError", comment: ""))
    }
}

extension AdaptiveRatingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (self.data?.count ?? 0) + (self.separatorPosition != nil ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LeaderboardTableViewCell.reuseId,
            for: indexPath
        ) as! LeaderboardTableViewCell

        let separatorAfterIndex = (self.separatorPosition ?? Int.max - 1)

        if separatorAfterIndex + 1 == indexPath.item {
            cell.isSeparator = true
        } else {
            let dataIndex = separatorAfterIndex < indexPath.item ? indexPath.item - 1 : indexPath.item

            if let user = data?[dataIndex] as? RatingViewData {
                cell.updateInfo(position: user.position, username: user.name, exp: user.exp, isMe: user.me)
            }
        }

        return cell
    }
}
