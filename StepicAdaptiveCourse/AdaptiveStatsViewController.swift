//
//  AdaptiveStatsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Charts

class AdaptiveStatsViewController: UIViewController, AdaptiveStatsView {
    var presenter: AdaptiveStatsPresenter?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressChart: LineChartView!
    @IBOutlet weak var currentWeekXPLabel: UILabel!
    @IBOutlet weak var bestStreakLabel: UILabel!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    fileprivate var achievements: [AchievementViewData] = []
    fileprivate var progressByWeek: [WeekProgressViewData] = []
    fileprivate var ratings: [RatingViewData] = []

    @IBAction func onSegmentedControlValueChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex != 2 {
            ratingSegmentedControl.isHidden = true
            tableView.reloadData()
        } else {
            ratingSegmentedControl.isHidden = false
            loadingIndicator.startAnimating()
            presenter?.reloadRatings(days: 7)
        }
    }

    @IBAction func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        presenter = AdaptiveStatsPresenter(statsManager: StatsManager.shared, ratingManager: RatingManager.shared, achievementsManager: AchievementManager.shared, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        setUpChart()

        presenter?.reloadStats()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = tableView.tableHeaderView else {
            return
        }

        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }

    func reload() {
        loadingIndicator.stopAnimating()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.reloadData()
    }

    func setProgress(records: [WeekProgressViewData]) {
        progressByWeek = records.reversed()
    }

    func setAchievements(records: [AchievementViewData]) {
        achievements = records
    }

    func setRatings(records: [RatingViewData]) {
        ratings = records
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

    fileprivate func valuesToDataEntries(values: [Int]) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }

        return dataEntries
    }

    fileprivate func setUpTable() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 112

        tableView.register(UINib(nibName: "ProgressTableViewCell", bundle: nil), forCellReuseIdentifier: ProgressTableViewCell.reuseId)
        tableView.register(UINib(nibName: "AchievementTableViewCell", bundle: nil), forCellReuseIdentifier: AchievementTableViewCell.reuseId)
        tableView.register(UINib(nibName: "LeaderboardTableViewCell", bundle: nil), forCellReuseIdentifier: LeaderboardTableViewCell.reuseId)
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
        dataSet.setColor(StepicApplicationsInfo.adaptiveMainColor)
        dataSet.mode = .horizontalBezier
        dataSet.cubicIntensity = 0.2
        dataSet.circleRadius = 4
        dataSet.circleHoleRadius = 2
        dataSet.fillColor = StepicApplicationsInfo.adaptiveMainColor
        dataSet.fillAlpha = 1.0
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = UIFont.systemFont(ofSize: 10)
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawCirclesEnabled = true
        dataSet.setCircleColor(StepicApplicationsInfo.adaptiveMainColor)
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)

        return dataSet
    }
}

extension AdaptiveStatsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return progressByWeek.count
        case 1: return achievements.count
        case 2: return ratings.count
        default: return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewCell.reuseId, for: indexPath) as! ProgressTableViewCell
            let weekProgress = progressByWeek[indexPath.item]
            cell.updateInfo(expCount: weekProgress.progress, begin: weekProgress.weekBegin, end: weekProgress.weekBegin.addingTimeInterval(6 * 24 * 60 * 60), isRecord: weekProgress.isRecord)
            return cell
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AchievementTableViewCell.reuseId, for: indexPath) as! AchievementTableViewCell
            let achievement = achievements[indexPath.item]
            cell.updateInfo(name: achievement.name, info: achievement.info, cover: achievement.cover, isUnlocked: achievement.isUnlocked, type: achievement.type, currentProgress: achievement.currentProgress, maxProgress: achievement.maxProgress)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableViewCell.reuseId, for: indexPath) as! LeaderboardTableViewCell
            let user = ratings[indexPath.item]
            cell.updateInfo(position: indexPath.item + 1, username: user.name, exp: user.exp, isMe: user.me)
            return cell
        }
    }

}
