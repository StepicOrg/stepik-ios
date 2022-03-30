//
//  SocialAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SVProgressHUD
import UIKit

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
        case .badConnection:
            SVProgressHUD.showError(withStatus: NSLocalizedString("BadConnectionAuth", comment: ""))
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .existingEmail(let email):
            if let url = URL(string: "\(StepikApplicationsInfo.social?.redirectUri ?? "")?error=social_signup_with_existing_email&email=\(email)") {
                UIApplication.shared.openURL(url)
            } else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
            }
        case .noEmail:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignInNoEmail", comment: ""))
        }
    }

    func presentWebController(with url: URL) {
        WebControllerManager.shared.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: .socialAuth,
            allowsSafari: false,
            backButtonStyle: .close,
            forceCustom: true
        )
    }

    func dismissWebController() {
        WebControllerManager.shared.dismissWebControllerWithKey(.socialAuth)
    }
}

final class SocialAuthViewController: UIViewController {
    var presenter: SocialAuthPresenter?

    private let numberOfColumns = 3
    private let numberOfRows = 2
    private let headerHeight: CGFloat = 47.0

    var isExpanded = false

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stepikLogoHeightConstraint: NSLayoutConstraint!

    private lazy var closeBarButtonItem = UIBarButtonItem.stepikCloseBarButtonItem(
        target: self,
        action: #selector(self.onCloseClick(_:))
    )

    private let analytics: Analytics = StepikAnalytics.shared

    private var providers: [SocialProviderViewData] = []

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
        self.analytics.send(.tappedSignInWithEmailOnSocialAuthScreen)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .email(email: nil))
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        self.analytics.send(.tappedSignUpOnSocialAuthScreen)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .registration)
        }
    }

    @IBAction func moreButtonClick(_ sender: Any) {
        isExpanded.toggle()

        moreButton.setTitle(
            isExpanded
                ? NSLocalizedString("SignInLessButton", comment: "")
                : NSLocalizedString("SignInMoreButton", comment: ""),
            for: .normal
        )

        collectionView.collectionViewLayout.invalidateLayout()
        self.updateCollectionViewHeight()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .top

        self.localize()
        self.colorize()

        self.presenter = SocialAuthPresenter(
            authAPI: ApiDataDownloader.auth,
            stepicsAPI: ApiDataDownloader.stepics,
            notificationStatusesAPI: NotificationStatusesAPI(),
            analytics: self.analytics,
            view: self
        )
        self.presenter?.update()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(cellClass: SocialAuthCollectionViewCell.self)

        let collectionViewLayout = SocialCollectionViewFlowLayout()
        collectionViewLayout.numberOfColumns = self.numberOfColumns
        self.collectionView.collectionViewLayout = collectionViewLayout

        // Small logo for small screens
        if DeviceInfo.current.diagonal <= 4 {
            self.stepikLogoHeightConstraint.constant = 38
        }

        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
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
        collectionViewHeight.constant = isExpanded
            ? (2 * layout.itemSize.height + layout.minimumInteritemSpacing + headerHeight) + 10
            : (layout.itemSize.height + headerHeight) + 5
    }

    private func localize() {
        self.signInButton.setTitle(NSLocalizedString("SignInEmailButton", comment: ""), for: .normal)
        self.signUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        self.moreButton.setTitle(NSLocalizedString("SignInMoreButton", comment: ""), for: .normal)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikBackground
        self.collectionView.backgroundColor = .clear
        self.moreButton.setTitleColor(.stepikGreen, for: .normal)
        self.signInButton.setTitleColor(.stepikPrimaryText, for: .normal)
        self.signUpButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }
}

extension SocialAuthViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.numberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if StepikApplicationsInfo.SocialInfo.isSignInWithAppleAvailable {
            return section == 0 ? self.numberOfColumns : self.numberOfColumns - 1
        } else {
            return section == 0 ? self.numberOfColumns : self.numberOfColumns - 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let providerIndex = indexPath.section * numberOfColumns + indexPath.item
        if providerIndex >= providers.count {
            return UICollectionViewCell()
        }

        let provider = providers[providerIndex]
        let cell: SocialAuthCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.image = provider.image

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let providerIndex = indexPath.section * numberOfColumns + indexPath.item
        if providerIndex >= providers.count {
            return
        }

        let provider = providers[providerIndex]
        self.analytics.send(.socialAuthProviderTapped(providerName: provider.name))

        presenter?.logIn(with: provider.id)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = true
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = false
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? SocialCollectionViewFlowLayout else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        // Center grid
        let width = collectionView.bounds.width
        let contentWidth = CGFloat(
            CGFloat(layout.numberOfColumns - 1) * layout.minimumInteritemSpacing + CGFloat(layout.numberOfColumns) * layout.itemSize.width
        )
        let leftOffset = (width - contentWidth) / 2

        // Add bottom offset for first section
        if section == 0 {
            return UIEdgeInsets(top: 0, left: leftOffset, bottom: layout.minimumLineSpacing, right: leftOffset)
        }

        return UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: leftOffset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SocialAuthHeaderView.reuseId,
                for: indexPath
            ) as? SocialAuthHeaderView {
                header.setup(title: presenter?.socialAuthHeaderString ?? "")
                return header
            }
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        // Add caption only for first section
        return section == 0 ? CGSize(width: collectionView.bounds.size.width, height: headerHeight) : CGSize.zero
    }
}

extension SocialAuthViewController: VKSocialSDKProviderDelegate {
    func presentAuthController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}

extension SocialAuthViewController: GoogleIDSocialSDKProviderDelegate {
    var googleSignInPresentingViewController: UIViewController? { self }
}

final class SocialCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
        set {}
        get {
            CGSize(width: itemSizeHeight, height: itemSizeHeight)
        }
    }
}
