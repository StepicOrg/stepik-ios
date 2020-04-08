import SVProgressHUD
import UIKit

final class StyledTabBarViewController: UITabBarController {
    enum Appearance {
        static let barTintColor = UIColor.stepikTabBar
        static let tintColor = UIColor.stepikAccent
        static let unselectedItemTintColor = UIColor.dynamic(
            light: UIColor(hex6: 0xBABAC1),
            dark: .stepikTertiaryText
        )
    }

    private let items = StepikApplicationsInfo.Modules.tabs?.compactMap { TabController(rawValue: $0)?.itemInfo } ?? []

    private var notificationsBadgeNumber: Int {
        get {
            if let notificationsTab = self.tabBar.items?.first(where: { $0.tag == TabController.notifications.tag }) {
                return Int(notificationsTab.badgeValue ?? "0") ?? 0
            }
            return 0
        }
        set {
            if let notificationsTab = self.tabBar.items?.first(where: { $0.tag == TabController.notifications.tag }) {
                notificationsTab.badgeValue = newValue > 0 ? "\(newValue)" : nil
                self.fixBadgePosition()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.barTintColor = Appearance.barTintColor
        self.tabBar.tintColor = Appearance.tintColor
        self.tabBar.unselectedItemTintColor = Appearance.unselectedItemTintColor
        self.tabBar.isTranslucent = false

        let tabBarViewControllers = self.items.map { tabBarItem -> UIViewController in
            let viewController = tabBarItem.controller
            viewController.tabBarItem = tabBarItem.makeTabBarItem()
            return viewController
        }
        self.setViewControllers(tabBarViewControllers, animated: false)
        self.fixBadgePosition()

        self.delegate = self

        if !AuthInfo.shared.isAuthorized {
            self.selectedIndex = TabController.explore.position
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didBadgeUpdate(systemNotification:)),
            name: .badgeUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didScreenRotate),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        self.updateSVProgressHUDDefaultStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !DefaultsContainer.launch.didLaunch {
            DefaultsContainer.launch.didLaunch = true

            let onboardingViewController = ControllerHelper.instantiateViewController(
                identifier: "Onboarding",
                storyboardName: "Onboarding"
            )
            onboardingViewController.modalPresentationStyle = .fullScreen

            self.present(onboardingViewController, animated: true)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateSVProgressHUDDefaultStyle()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Private API

    // FIXME: Create SVProgressHUD configurator.
    private func updateSVProgressHUDDefaultStyle() {
        SVProgressHUD.setDefaultStyle(self.view.isDarkInterfaceStyle ? .dark : .light)
    }

    @objc
    private func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let value = userInfo["value"] as? Int else {
            return
        }

        self.notificationsBadgeNumber = value
    }

    @objc
    private func didScreenRotate() {
        DispatchQueue.main.async {
            self.fixBadgePosition()
        }
    }

    private func fixBadgePosition() {
        for i in 1...items.count {
            if i >= tabBar.subviews.count { break }

            for badgeView in tabBar.subviews[i].subviews {
                if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                    badgeView.layer.transform = CATransform3DIdentity

                    if DeviceInfo.current.orientation.interface.isLandscape {
                        badgeView.layer.transform = CATransform3DMakeTranslation(-2.0, 5.0, 1.0)
                    } else {
                        if DeviceInfo.current.isPad {
                            badgeView.layer.transform = CATransform3DMakeTranslation(1.0, 3.0, 1.0)
                        } else {
                            badgeView.layer.transform = CATransform3DMakeTranslation(-6.0, -1.0, 1.0)
                        }
                    }
                }
            }
        }
    }
}

extension StyledTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController),
              let eventName = self.items[safe: selectedIndex]?.clickEventName else {
            return
        }

        AnalyticsReporter.reportEvent(eventName)
    }
}

private struct TabBarItemInfo {
    var title: String
    var controller: UIViewController
    var clickEventName: String
    var image: UIImage?
    var selectedImage: UIImage?
    var tag: Int

    func makeTabBarItem() -> UITabBarItem {
        let item = UITabBarItem(title: self.title, image: self.image, selectedImage: self.selectedImage)
        item.tag = self.tag
        return item
    }
}

private enum TabController: String {
    case profile = "Profile"
    case home = "Home"
    case notifications = "Notifications"
    case explore = "Catalog"

    var tag: Int { self.hashValue }

    var position: Int {
        switch self {
        case .home:
            return 0
        case .explore:
            return 1
        case .profile:
            return 2
        case .notifications:
            return 3
        }
    }

    var itemInfo: TabBarItemInfo {
        switch self {
        case .profile:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "ProfileNavigation",
                storyboardName: "Main"
            )

            let personImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "person")
                } else {
                    return UIImage(named: "tab-profile").require()
                }
            }()

            let personFillImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "person.fill")
                } else {
                    return personImage
                }
            }()

            return TabBarItemInfo(
                title: NSLocalizedString("Profile", comment: ""),
                controller: viewController,
                clickEventName: AnalyticsEvents.Tabs.profileClicked,
                image: personImage,
                selectedImage: personFillImage,
                tag: self.tag
            )
        case .home:
            let viewController = HomeAssembly().makeModule()
            let navigationViewController = StyledNavigationController(
                rootViewController: viewController
            )

            let homeImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "house")
                } else {
                    return UIImage(named: "tab-home").require()
                }
            }()

            let homeFillImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "house.fill")
                } else {
                    return homeImage
                }
            }()

            return TabBarItemInfo(
                title: NSLocalizedString("Home", comment: ""),
                controller: navigationViewController,
                clickEventName: AnalyticsEvents.Tabs.myCoursesClicked,
                image: homeImage,
                selectedImage: homeFillImage,
                tag: self.tag
            )
        case .notifications:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "NotificationsNavigation",
                storyboardName: "Main"
            )

            let notificationsImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "bell")
                } else {
                    return UIImage(named: "tab-notifications").require()
                }
            }()

            let notificationsFillImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "bell.fill")
                } else {
                    return notificationsImage
                }
            }()

            return TabBarItemInfo(
                title: NSLocalizedString("Notifications", comment: ""),
                controller: viewController,
                clickEventName: AnalyticsEvents.Tabs.notificationsClicked,
                image: notificationsImage,
                selectedImage: notificationsFillImage,
                tag: self.tag
            )
        case .explore:
            let viewController = ExploreAssembly().makeModule()
            let navigationViewController = StyledNavigationController(
                rootViewController: viewController
            )

            let exploreImage: UIImage? = {
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "magnifyingglass")
                } else {
                    return UIImage(named: "tab-explore").require()
                }
            }()

            return TabBarItemInfo(
                title: NSLocalizedString("Catalog", comment: ""),
                controller: navigationViewController,
                clickEventName: AnalyticsEvents.Tabs.catalogClicked,
                image: exploreImage,
                selectedImage: exploreImage,
                tag: self.tag
            )
        }
    }
}
