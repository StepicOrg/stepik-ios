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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currentWeekXPLabel: UILabel!
    @IBOutlet weak var bestStreakLabel: UILabel!
    @IBOutlet weak var currentLevelLabel: UILabel!
    
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presenter = AdaptiveStatsPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        setUpChart()
        
        currentLevelLabel.text = "\(presenter?.currentLevel ?? 0)"
        bestStreakLabel.text = "\(presenter?.bestStreak ?? 0)"
        currentWeekXPLabel.text = "\(presenter?.currentWeekXP ?? 0)"
        
        // Load data
        let dataSet = updateDataSet(LineChartDataSet(values: valuesToDataEntries(values: presenter?.last7DaysProgress.reversed() ?? []), label: ""))
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
        tableView.delegate = self
        tableView.dataSource = self
    
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
        return presenter?.progressByWeek.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! ProgressTableViewCell
        if let weekProgress = presenter?.progressByWeek[indexPath.item] {
            cell.updateInfo(expCount: weekProgress.progress, begin: weekProgress.weekBegin, end: weekProgress.weekBegin.addingTimeInterval(6 * 24 * 60 * 60), isRecord: weekProgress.isRecord)
        }
        return cell
    }

}
