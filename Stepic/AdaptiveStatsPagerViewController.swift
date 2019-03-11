//
//  AdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveStatsPagerViewController: PagerController {

    var sections: [AdaptiveStatsSection] {
        return [.progress, .rating]
    }

    var statsManager: AdaptiveStatsManager?
    var ratingsManager: AdaptiveRatingManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

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

    internal func controllerForSection(_ section: AdaptiveStatsSection) -> UIViewController {
        guard let statsManager = self.statsManager, let ratingsManager = self.ratingsManager else {
            return UIViewController()
        }

        switch section {
        case .progress:
            let vc = ControllerHelper.instantiateViewController(identifier: "Progress", storyboardName: "Adaptive") as! AdaptiveStatsViewController
            vc.presenter = AdaptiveStatsPresenter(statsManager: statsManager, ratingManager: ratingsManager, view: vc)
            return vc
        case .rating:
            let vc = ControllerHelper.instantiateViewController(identifier: "Ratings", storyboardName: "Adaptive") as! AdaptiveRatingsViewController
            vc.presenter = AdaptiveRatingsPresenter(ratingsAPI: AdaptiveRatingsAPI(), usersAPI: UsersAPI(), ratingManager: ratingsManager, view: vc)
            return vc
        default:
            return UIViewController()
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
        return controllerForSection(sections[index])
    }
}

extension AdaptiveStatsPagerViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return .init(shadowViewAlpha: 0.0)
    }
}
