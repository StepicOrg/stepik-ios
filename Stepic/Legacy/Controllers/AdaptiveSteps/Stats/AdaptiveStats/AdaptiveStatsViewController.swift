//
//  AdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Charts
import UIKit

final class AdaptiveStatsViewController: UIViewController {
    enum State {
        case empty(message: String)
        case error(message: String)
        case loading
        case normal(message: String?)
    }

    private var state: State = .loading {
        didSet {
            switch state {
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

    var presenter: AdaptiveStatsPresenter?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressChart: LineChartView!
    @IBOutlet weak var currentWeekXPLabel: UILabel!
    @IBOutlet weak var bestStreakLabel: UILabel!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var allCountLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var progressByWeeksTitleLabel: UILabel!
    @IBOutlet weak var levelTitleLabel: UILabel!
    @IBOutlet weak var streakTitleLabel: UILabel!
    @IBOutlet weak var xpPer7DaysTitleLabel: UILabel!
    @IBOutlet weak var last7DaysTitleLabel: UILabel!

    @IBOutlet var mainStatHorizontalSeparator: UIView!
    @IBOutlet var mainStatVerticalSeparator: UIView!
    @IBOutlet var progressVerticalSeparator: UIView!

    private var data: [Any]?

    @IBAction
    func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.colorize()
        self.localize()

        self.setUpTable()
        self.setUpChart()

        self.presenter?.reloadStats()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.reloadData(force: data == nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = self.tableView.tableHeaderView else {
            return
        }

        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            self.tableView.tableHeaderView = headerView
            self.tableView.layoutIfNeeded()
        }
    }

    private func colorize() {
        [
            self.currentLevelLabel,
            self.bestStreakLabel,
            self.currentWeekXPLabel
        ].forEach { $0?.textColor = .stepikAccent }

        [
            self.levelTitleLabel,
            self.streakTitleLabel,
            self.xpPer7DaysTitleLabel
        ].forEach { $0?.textColor = .stepikSystemGray }

        [
            self.last7DaysTitleLabel,
            self.progressByWeeksTitleLabel,
            self.allCountLabel
        ].forEach { $0?.textColor = .stepikSystemGray2 }

        [
            self.mainStatHorizontalSeparator,
            self.mainStatVerticalSeparator,
            self.progressVerticalSeparator
        ].forEach { $0?.backgroundColor = .stepikOpaqueSeparator }

        self.view.backgroundColor = .stepikBackground
        self.loadingIndicator.color = .stepikLoadingIndicator
    }

    private func localize() {
        self.levelTitleLabel.text = NSLocalizedString("AdaptiveLevelSuffix", comment: "")
        self.streakTitleLabel.text = NSLocalizedString("AdaptiveBestStreak", comment: "")
        self.xpPer7DaysTitleLabel.text = NSLocalizedString("AdaptiveXPperWeek", comment: "")
        self.last7DaysTitleLabel.text = NSLocalizedString("AdaptiveLast7Days", comment: "")
        self.progressByWeeksTitleLabel.text = NSLocalizedString("AdaptiveProgressByWeeks", comment: "")
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

    private func valuesToDataEntries(values: [Int]) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }

        return dataEntries
    }

    private func setUpTable() {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 112

        self.tableView.register(
            UINib(nibName: "ProgressTableViewCell", bundle: nil),
            forCellReuseIdentifier: ProgressTableViewCell.reuseId
        )
    }

    private func setUpChart() {
        self.progressChart.chartDescription.enabled = false
        self.progressChart.isUserInteractionEnabled = false
        self.progressChart.setScaleEnabled(false)
        self.progressChart.pinchZoomEnabled = false
        self.progressChart.drawGridBackgroundEnabled = false
        self.progressChart.dragEnabled = false
        self.progressChart.xAxis.enabled = false
        self.progressChart.leftAxis.enabled = false
        self.progressChart.rightAxis.enabled = false
        self.progressChart.legend.enabled = false
    }

    private func updateDataSet(_ dataSet: LineChartDataSet) -> LineChartDataSet {
        dataSet.setColor(.stepikAccent)
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.circleRadius = 4
        dataSet.circleHoleRadius = 2
        dataSet.fillColor = .stepikAccent
        dataSet.fillAlpha = 1.0
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = UIFont.systemFont(ofSize: 10)
        dataSet.valueTextColor = .stepikAccent
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawCirclesEnabled = true
        dataSet.setCircleColor(.stepikAccent)
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)

        return dataSet
    }
}

extension AdaptiveStatsViewController: AdaptiveStatsView {
    func setProgress(records: [WeekProgressViewData]) {
        self.data = records
    }

    func setGeneralStats(currentLevel: Int, bestStreak: Int, currentWeekXP: Int, last7DaysProgress: [Int]?) {
        self.currentLevelLabel.text = "\(currentLevel)"
        self.bestStreakLabel.text = "\(bestStreak)"
        self.currentWeekXPLabel.text = "\(currentWeekXP)"

        guard let last7DaysProgress = last7DaysProgress else {
            return
        }

        let dataSet = self.updateDataSet(
            LineChartDataSet(entries: self.valuesToDataEntries(values: last7DaysProgress.reversed()), label: "")
        )
        let data = LineChartData(dataSet: dataSet)

        self.progressChart.data = data
        self.progressChart.data?.isHighlightEnabled = true
        self.progressChart.animate(yAxisDuration: 1.4, easingOption: .easeInOutCirc)
    }
}

extension AdaptiveStatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.data?.count ?? 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProgressTableViewCell.reuseId,
            for: indexPath
        ) as! ProgressTableViewCell

        if let weekProgress = data?[indexPath.item] as? WeekProgressViewData {
            cell.updateInfo(
                expCount: weekProgress.progress,
                begin: weekProgress.weekBegin,
                end: weekProgress.weekBegin.addingTimeInterval(6 * 24 * 60 * 60),
                isRecord: weekProgress.isRecord
            )
        }

        return cell
    }
}
