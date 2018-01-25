//
//  AdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveStatsPagerViewController: PagerController {
    enum Section {
        var localizedName: String {
            switch self {
            case .progress:
                return NSLocalizedString("AdaptiveProgress", comment: "")
            case .rating:
                return NSLocalizedString("AdaptiveRating", comment: "")
            }
        }

        case progress
        case rating
    }

    var sections: [Section] = [.progress, .rating]

    var statsManager: AdaptiveStatsManager?
    var ratingsManager: AdaptiveRatingManager?

    @IBAction func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("AdaptiveStats", comment: "")

        self.dataSource = self
        setUpTabs()
    }

    fileprivate func setUpTabs() {
        tabHeight = 44.0
        indicatorHeight = 1.5
        centerCurrentTab = true
        indicatorColor = UIColor.mainDark
        selectedTabTextColor = UIColor.mainDark
        tabsTextColor = UIColor.mainDark
        tabsTextFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        tabsViewBackgroundColor = UIColor.mainLight
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }
}

extension AdaptiveStatsPagerViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int {
        return sections.count
    }

    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        label.text = sections[index].localizedName
        label.sizeToFit()
        return label
    }

    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        guard let statsManager = self.statsManager, let ratingsManager = self.ratingsManager else {
            return UIViewController()
        }

        switch sections[index] {
        case .progress:
            let vc = ControllerHelper.instantiateViewController(identifier: "Progress", storyboardName: "Adaptive") as! AdaptiveStatsViewController
            vc.statsPresenter = AdaptiveStatsPresenter(statsManager: statsManager, ratingManager: ratingsManager, view: vc)
            return vc
        case .rating:
            let vc = ControllerHelper.instantiateViewController(identifier: "Ratings", storyboardName: "Adaptive") as! AdaptiveRatingsViewController
            vc.ratingsPresenter = AdaptiveRatingsPresenter(ratingsAPI: AdaptiveRatingsAPI(), ratingManager: ratingsManager, view: vc)
            return vc
        }
    }
}

extension AdaptiveStatsPagerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navController = navigationController as? StyledNavigationViewController else {
            return
        }

        navController.changeShadowAlpha(0)
    }
}
