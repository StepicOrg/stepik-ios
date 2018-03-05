//
//  AppDelegate.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 15/10/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Add a search view controller to the root `UITabBarController`.
        if let tabController = window?.rootViewController as? UITabBarController {
            let searchController = packagedSearchController()
            tabController.viewControllers?.append(searchController)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func packagedSearchController() -> UIViewController {
        // Load a `SearchResultsViewController` from its storyboard.
        let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .vertical
        let searchResultsController = SearchResultsViewController(collectionViewLayout: flowLayout)

        /*
         Create a UISearchController, passing the `searchResultsController` to
         use to display search results.
         */
        let searchController = UISearchController(searchResultsController: searchResultsController)
        let rect = UIScreen.main.bounds
        let view = BlurredView(frame: rect, style: .extraLight, image: #imageLiteral(resourceName: "background"))
        searchController.view.insertSubview(view, at: 0)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("Enter course name", comment: "")

        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")

        // Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)
        return searchNavigationController
    }

}
