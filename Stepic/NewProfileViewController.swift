//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr
import DZNEmptyDataSet

class NewProfileViewController: MenuViewController, ProfileView {

    var presenter: ProfilePresenter?
    var shareBarButtonItem: UIBarButtonItem?

    var state: ProfileState = .refreshing

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ProfilePresenter(view: self, userActivitiesAPI: ApiDataDownloader.userActivities, usersAPI: ApiDataDownloader.users)
        shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(NewProfileViewController.shareButtonPressed))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem!

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
//        }
        self.title = NSLocalizedString("Profile", comment: "")
    }

    func shareButtonPressed() {
        presenter?.sharePressed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var profile: ProfileData? {
        didSet {
            profileStreaksView?.profile = profile
        }
    }
    var streaks: StreakData? {
        didSet {
            profileStreaksView?.streaks = streaks
        }
    }

    var profileStreaksView: ProfileStreaksView?

    func refreshProfileStreaksView() {
        profileStreaksView = ProfileStreaksView(frame: CGRect.zero)
        guard let profileStreaksView = profileStreaksView else {
            return
        }
        profileStreaksView.profile = profile
        profileStreaksView.streaks = streaks
        profileStreaksView.frame.size = profileStreaksView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

    func setEmpty() {
        self.tableView.tableHeaderView = nil
        self.menu = Menu(blocks: [])
        self.profile = nil
        self.streaks = nil
    }

    // MARK: - ProfileView

    func set(state: ProfileState) {
        self.state = state
        switch state {
        case .authorized:
            self.menu = presenter?.menu
            refreshProfileStreaksView()
            tableView.tableHeaderView = profileStreaksView
            break
        default:
            setEmpty()
            break
        }
    }

    func set(profile: ProfileData?) {
        self.profile = profile
    }

    func set(streaks: StreakData?) {
        self.streaks = streaks
    }

    func set(menu: Menu) {
        self.menu = menu
    }

    func showNotificationSettingsAlert(completion: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: {
            completion?()
        })
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .bottomHalf)
        return streakTimePickerPresenter
    }()

    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?) {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = startHour
        vc.selectedBlock = {
            selectedBlock?()
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    func showShareProfileAlert(url: URL) {
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let shareVC = SharingHelper.getSharingController(url.absoluteString)
            shareVC.popoverPresentationController?.barButtonItem = self?.shareBarButtonItem
            DispatchQueue.main.async {
                [weak self] in
                self?.present(shareVC, animated: true, completion: nil)
            }
        }
    }

    func logout(onBack: (() -> Void)?) {
        AuthInfo.shared.token = nil
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func navigateToSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    func navigateToDownloads() {
        let vc = ControllerHelper.instantiateViewController(identifier: "DownloadsViewController", storyboardName: "Main")
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.updateProfile()
        (self.navigationController as? StyledNavigationViewController)?.setStatusBarStyle()
    }
}

extension NewProfileViewController : DZNEmptyDataSetDelegate {
    @objc func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }

    @objc func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        switch state {
        case .anonymous:
            let vc = ControllerHelper.getAuthController()
            self.present(vc, animated: true, completion: nil)
            break
        case .error:
            presenter?.updateProfile()
            break
        default:
            break
        }
    }
}

extension NewProfileViewController : DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        switch state {
        case .anonymous:
            return Images.placeholders.anonymous
        case .error:
            return Images.placeholders.connectionError
        case .refreshing:
            return Images.placeholders.anonymous
        default:
            return UIImage()
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String = ""

        switch state {
        case .anonymous:
            text = NSLocalizedString("ProfileAnonymousTitle", comment: "")
        case .error:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("Refreshing", comment: "")
            break
        default:
            break
        }

        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String = ""

        switch state {
        case .anonymous:
            text = NSLocalizedString("ProfileAnonymousSubtitle", comment: "")
            break
        case .error:
            text = ""
            break
        case .refreshing:
            text = NSLocalizedString("RefreshingDescription", comment: "")
            break
        default:
            break
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center

        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0),
                          NSForegroundColorAttributeName: UIColor.lightGray,
                          NSParagraphStyleAttributeName: paragraph]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        var text: String = ""

        switch self.state {
        case .anonymous:
            text = NSLocalizedString("SignIn", comment: "")
        case .error:
            text = NSLocalizedString("TryAgain", comment: "")
            break
        case .refreshing:
            text = ""
            break
        default:
            break
        }

        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0),
                          NSForegroundColorAttributeName: UIColor.mainDark]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.groupTableViewBackground
    }
}
