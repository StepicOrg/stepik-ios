//
//  SocialAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

extension SocialAuthViewController: SocialAuthView {
    func set(providers: [SocialProviderViewData]) {
        self.providers = providers
    }

    func update(with result: SocialAuthResult) {
        guard let navigationController = self.navigationController as? AuthNavigationViewController else {
            return
        }

        state = .normal

        switch result {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
            navigationController.dismissAfterSuccess()
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .existingEmail(let email):
            if let url = URL(string: "\(StepicApplicationsInfo.social?.redirectUri ?? "")?error=social_signup_with_existing_email&email=\(email)") {
                UIApplication.shared.openURL(url)
            } else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
            }
        }
    }

    func presentWebController(with url: URL) {
        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: webControllerKey, allowsSafari: false, backButtonStyle: BackButtonStyle.close, forceCustom: true)
    }

    func dismissWebController() {
        WebControllerManager.sharedManager.dismissWebControllerWithKey(webControllerKey, animated: true, completion: nil, error: nil)
    }
}

class SocialAuthViewController: UIViewController {
    var presenter: SocialAuthPresenter?

    fileprivate let numberOfColumns = 3
    fileprivate let numberOfRows = 2
    fileprivate let headerHeight: CGFloat = 47.0

    fileprivate let webControllerKey = "social auth"

    var isExpanded = false

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var providers: [SocialProviderViewData] = []

    var state: SocialAuthState = .normal {
        didSet {
            switch state {
            case .normal:
                SVProgressHUD.dismiss()
            case .loading:
                SVProgressHUD.show()
            }
        }
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: nil)
        }
    }

    @IBAction func onSignInWithEmailClick(_ sender: Any) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onSocialAuth, parameters: nil)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .email(email: nil))
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onSocialAuth, parameters: nil)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .registration)
        }
    }

    @IBAction func moreButtonClick(_ sender: Any) {
        isExpanded = !isExpanded

        moreButton.setTitle(isExpanded ? NSLocalizedString("SignInLessButton", comment: "") : NSLocalizedString("SignInMoreButton", comment: ""), for: .normal)

        collectionView.collectionViewLayout.invalidateLayout()
        self.updateCollectionViewHeight()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        presenter = SocialAuthPresenter(authManager: AuthManager.sharedManager, stepicsAPI: ApiDataDownloader.stepics, view: self)
        presenter?.update()

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SocialAuthCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SocialAuthCollectionViewCell.reuseId)

        let collectionViewLayout = SocialCollectionViewFlowLayout()
        collectionViewLayout.numberOfColumns = numberOfColumns
        collectionView.collectionViewLayout = collectionViewLayout
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateCollectionViewHeight() {
        guard let layout = self.collectionView.collectionViewLayout as? SocialCollectionViewFlowLayout else {
            return
        }

        // Add additional offset for shadows
        collectionViewHeight.constant = isExpanded ? (2 * layout.itemSize.height + layout.minimumInteritemSpacing + headerHeight) + 10 : (layout.itemSize.height + headerHeight) + 5
    }

    private func localize() {
        signInButton.setTitle(NSLocalizedString("SignInEmailButton", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        moreButton.setTitle(NSLocalizedString("SignInMoreButton", comment: ""), for: .normal)
    }
}

extension SocialAuthViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let providerIndex = indexPath.section * numberOfColumns + indexPath.item
        if providerIndex >= providers.count {
            return UICollectionViewCell()
        }

        let provider = providers[providerIndex]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialAuthCollectionViewCell.reuseId, for: indexPath) as! SocialAuthCollectionViewCell

        cell.imageView.image = provider.image

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let providerIndex = indexPath.section * numberOfColumns + indexPath.item
        if providerIndex >= providers.count {
            return
        }

        let provider = providers[providerIndex]
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Social.clicked, parameters: ["social": provider.name])

        presenter?.logIn(with: provider.id)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = true
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = false
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? SocialCollectionViewFlowLayout else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        // Center grid
        let width = collectionView.bounds.width
        let contentWidth = CGFloat(CGFloat(layout.numberOfColumns - 1) * layout.minimumInteritemSpacing + CGFloat(layout.numberOfColumns) * layout.itemSize.width)
        let leftOffset = (width - contentWidth) / 2

        // Add bottom offset for first section
        if section == 0 {
            return UIEdgeInsets(top: 0, left: leftOffset, bottom: layout.minimumLineSpacing, right: leftOffset)
        }
        return UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: leftOffset)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SocialAuthHeaderView.reuseId, for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Add caption only for first section
        return section == 0 ? CGSize(width: collectionView.bounds.size.width, height: headerHeight) : CGSize.zero
    }
}

extension SocialAuthViewController: VKSocialSDKProviderDelegate {
    func presentAuthController(_ controller: UIViewController) {
        // FIXME: register URL
        if let registerURL = SocialProvider.vk.info.registerURL {
            WebControllerManager.sharedManager.presentWebControllerWithURL(registerURL, inController: self, withKey: "social auth", allowsSafari: false, backButtonStyle: BackButtonStyle.close, forceCustom: true)
        }
    }
}

class SocialCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var numberOfColumns: Int = 3
    var itemSizeHeight: CGFloat = 51.0

    private func setup() {
        minimumLineSpacing = 27.0
        minimumInteritemSpacing = 23.0
        scrollDirection = .vertical
    }

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override var itemSize: CGSize {
        set { }
        get {
            return CGSize(width: itemSizeHeight, height: itemSizeHeight)
        }
    }
}
