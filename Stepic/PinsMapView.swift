//
//  PinsMapView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PinsMapView: NibInitializableView {
    @IBOutlet weak var monthsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!

    override var nibName: String {
        return "PinsMapView"
    }

    func buildMonth(_ month: PinsMap.Month) -> PinsMapMonthView {
        return PinsMapMonthView()
    }

    func buildMonths(_ pins: [Int]) {
        /* For tests */
        let pm1 = PinsMapMonthView()
        let pm2 = PinsMapMonthView()
        let pm3 = PinsMapMonthView()
        let pm4 = PinsMapMonthView()
        let pm5 = PinsMapMonthView()
        let pm6 = PinsMapMonthView()
        let pm7 = PinsMapMonthView()
        let pm8 = PinsMapMonthView()
        let pm9 = PinsMapMonthView()
        let pm10 = PinsMapMonthView()
        let pm11 = PinsMapMonthView()
        let pm12 = PinsMapMonthView()

        var days = (1...28).map { _ in PinsMapMonthView.Day.solved(pin: 0) }
        pm1.set(monthTitle: "Январь", days: days)
        pm2.set(monthTitle: "Февраль", days: days)
        pm3.set(monthTitle: "Март", days: days)
        pm4.set(monthTitle: "Апрель", days: days)
        pm5.set(monthTitle: "Май", days: days)
        pm6.set(monthTitle: "Июнь", days: days)
        pm7.set(monthTitle: "Июль", days: days)
        pm8.set(monthTitle: "Август", days: days)
        pm9.set(monthTitle: "Сентябрь", days: days)
        pm10.set(monthTitle: "Октябрь", days: days)
        pm11.set(monthTitle: "Ноябрь", days: days)
        pm12.set(monthTitle: "Декабрь", days: days)

        monthsStackView.addArrangedSubview(pm1)
        monthsStackView.addArrangedSubview(pm2)
        monthsStackView.addArrangedSubview(pm3)
        monthsStackView.addArrangedSubview(pm4)

        monthsStackView.addArrangedSubview(pm5)
        monthsStackView.addArrangedSubview(pm6)
        monthsStackView.addArrangedSubview(pm7)
        monthsStackView.addArrangedSubview(pm8)

        monthsStackView.addArrangedSubview(pm9)
        monthsStackView.addArrangedSubview(pm10)
        monthsStackView.addArrangedSubview(pm11)
        monthsStackView.addArrangedSubview(pm12)
    }

    override func setupSubviews() {
        scrollView.delegate = self
    }
}

extension PinsMapView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}
