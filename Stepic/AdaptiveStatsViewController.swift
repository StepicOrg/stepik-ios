//
//  AdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Charts

class AdaptiveStatsViewController: UIViewController {
    enum State {
        case empty(message: String)
        case error(message: String)
        case loading
        case normal(message: String?)
    }

    fileprivate var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                data = nil
                tableView.reloadData()
                loadingIndicator.startAnimating()
                allCountLabel.isHidden = true
            case .empty(let message), .error(let message):
                loadingIndicator.stopAnimating()
                allCountLabel.text = message
                allCountLabel.isHidden = false
            case .normal(let message):
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                if let message = message {
                    allCountLabel.text = message
                    allCountLabel.isHidden = false
                } else {
                    allCountLabel.isHidden = true
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

    fileprivate var data: [Any]?

    @IBAction func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        colorize()
        localize()

        setUpTable()
        setUpChart()

        presenter?.reloadStats()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.reloadData(force: data == nil)
    }

    fileprivate func colorize() {
        currentWeekXPLabel.textColor = UIColor.mainDark
        bestStreakLabel.textColor = UIColor.mainDark
        currentLevelLabel.textColor = UIColor.mainDark
    }

    private func localize() {
        levelTitleLabel.text = NSLocalizedString("AdaptiveLevelSuffix", comment: "")
        streakTitleLabel.text = NSLocalizedString("AdaptiveBestStreak", comment: "")
        xpPer7DaysTitleLabel.text = NSLocalizedString("AdaptiveXPperWeek", comment: "")
        last7DaysTitleLabel.text = NSLocalizedString("AdaptiveLast7Days", comment: "")
        progressByWeeksTitleLabel.text = NSLocalizedString("AdaptiveProgressByWeeks", comment: "")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = tableView.tableHeaderView else {
            return
        }

        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }

    func reload() {
        if data == nil {
            state = .empty(message: NSLocalizedString("AdaptiveProgressWeeksEmpty", comment: ""))
        } else {
            switch state {
            case .normal(let message):
                state = .normal(message: message)
            default:
                state = .normal(message: nil)
            }
        }
    }

    fileprivate func valuesToDataEntries(values: [Int]) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }

        return dataEntries
    }

    fileprivate func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112

        tableView.register(UINib(nibName: "ProgressTableViewCell", bundle: nil), forCellReuseIdentifier: ProgressTableViewCell.reuseId)
    }

    fileprivate func setUpChart() {
        progressChart.chartDescription?.enabled = false
        progressChart.isUserInteractionEnabled = false
        progressChart.setScaleEnabled(false)
        progressChart.pinchZoomEnabled = false
        progressChart.drawGridBackgroundEnabled = false
        progressChart.dragEnabled = false
        progressChart.xAxis.enabled = false
        progressChart.leftAxis.enabled = false
        progressChart.rightAxis.enabled = false
        progressChart.legend.enabled = false
    }

    fileprivate func updateDataSet(_ dataSet: LineChartDataSet) -> LineChartDataSet {
        dataSet.setColor(UIColor.mainDark)
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.circleRadius = 4
        dataSet.circleHoleRadius = 2
        dataSet.fillColor = UIColor.mainDark
        dataSet.fillAlpha = 1.0
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = UIFont.systemFont(ofSize: 10)
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawCirclesEnabled = true
        dataSet.setCircleColor(UIColor.mainDark)
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)

        return dataSet
    }
}

extension AdaptiveStatsViewController: AdaptiveStatsView {
    func setProgress(records: [WeekProgressViewData]) {
        data = records
    }

    func setGeneralStats(currentLevel: Int, bestStreak: Int, currentWeekXP: Int, last7DaysProgress: [Int]?) {
        currentLevelLabel.text = "\(currentLevel)"
        bestStreakLabel.text = "\(bestStreak)"
        currentWeekXPLabel.text = "\(currentWeekXP)"

        guard let last7DaysProgress = last7DaysProgress else {
            return
        }

        let dataSet = updateDataSet(LineChartDataSet(values: valuesToDataEntries(values: last7DaysProgress.reversed()), label: ""))
        let data = LineChartData(dataSet: dataSet)
        progressChart.data = data
        progressChart.data?.highlightEnabled = true
        progressChart.animate(yAxisDuration: 1.4, easingOption: .easeInOutCirc)
    }
}

extension AdaptiveStatsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewCell.reuseId, for: indexPath) as! ProgressTableViewCell
        if let weekProgress = data?[indexPath.item] as? WeekProgressViewData {
            cell.updateInfo(expCount: weekProgress.progress, begin: weekProgress.weekBegin, end: weekProgress.weekBegin.addingTimeInterval(6 * 24 * 60 * 60), isRecord: weekProgress.isRecord)
        }
        return cell
    }
}
