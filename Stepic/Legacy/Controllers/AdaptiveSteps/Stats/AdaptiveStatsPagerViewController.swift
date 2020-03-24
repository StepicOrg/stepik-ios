//
//  AdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class AdaptiveStatsPagerViewController: PagerController {
    var sections: [AdaptiveStatsSection] { [.progress, .rating] }

    var statsManager: AdaptiveStatsManager?
    var ratingsManager: AdaptiveRatingManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.title = NSLocalizedString("AdaptiveStats", comment: "")

        self.dataSource = self
        self.setUpTabs()
    }

    private func setUpTabs() {
        self.tabHeight = 44.0
        self.indicatorHeight = 1.5
        self.centerCurrentTab = true
        self.indicatorColor = .stepikAccent
        self.selectedTabTextColor = .stepikAccent
        self.tabsTextColor = .stepikAccent
        self.tabsTextFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        self.tabsViewBackgroundColor = .stepikBackground
    }

    internal func controllerForSection(_ section: AdaptiveStatsSection) -> UIViewController {
        guard let statsManager = self.statsManager, let ratingsManager = self.ratingsManager else {
            return UIViewController()
        }

        switch section {
        case .progress:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "Progress",
                storyboardName: "Adaptive"
            ) as! AdaptiveStatsViewController

            viewController.presenter = AdaptiveStatsPresenter(
                statsManager: statsManager,
                ratingManager: ratingsManager,
                view: viewController
            )

            return viewController
        case .rating:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "Ratings",
                storyboardName: "Adaptive"
            ) as! AdaptiveRatingsViewController

            viewController.presenter = AdaptiveRatingsPresenter(
                ratingsAPI: AdaptiveRatingsAPI(),
                usersAPI: UsersAPI(),
                ratingManager: ratingsManager,
                view: viewController
            )

            return viewController
        default:
            return UIViewController()
        }
    }
}

extension AdaptiveStatsPagerViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int { self.sections.count }

    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.text = self.sections[index].localizedName
        label.sizeToFit()

        return label
    }

    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        self.controllerForSection(sections[index])
    }
}

extension AdaptiveStatsPagerViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        .init(shadowViewAlpha: 0.0)
    }
}
