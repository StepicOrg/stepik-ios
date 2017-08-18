//
//  SocialNetworksViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SafariServices
import SVProgressHUD

class SocialNetworksViewController: UIViewController {

    @IBOutlet weak var socialNetworksCollectionView: UICollectionView!

    var cellSize: CGFloat = 50
    let cellSpacing: CGFloat = 10

    let socialNetworks = SocialNetworks.all

    var dismissBlock : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        socialNetworksCollectionView.delegate = self
        socialNetworksCollectionView.dataSource = self

        socialNetworksCollectionView.register(UINib(nibName: "SocialNetworkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SocialNetworkCollectionViewCell")

//        print("collection view cancels touches -> \(socialNetworksCollectionView.panGestureRecognizer.cancelsTouchesInView)")
        initializeTapRecognizer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        socialNetworksCollectionView.performBatchUpdates(nil, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func initializeTapRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SocialNetworksViewController.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = true
        socialNetworksCollectionView.addGestureRecognizer(tapGesture)
    }

    func handleTap(_ sender: UITapGestureRecognizer!) {
        let location = sender.location(ofTouch: 0, in: socialNetworksCollectionView)
        let locationInCollection = CGPoint(x: location.x, y: location.y)
        let indexPathOptional = socialNetworksCollectionView.indexPathForItem(at: locationInCollection)
        if let indexPath = indexPathOptional {
            AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Social.clicked, parameters: ["social": "\(getSocialNetworkByIndexPath(indexPath).name!)" as NSObject])
            let socialNetwork = getSocialNetworkByIndexPath(indexPath)
            if let provider = socialNetwork.socialSDKProvider {
                if provider is VKSocialSDKProvider {
                    (provider as! VKSocialSDKProvider).delegate = self
                }

                provider.getAccessInfo(success: {
                    token, email in
                    SVProgressHUD.show(withStatus: "")
                    AuthManager.oauth.signUpWith(socialToken: token, email: email, provider: provider.name, success: { t in
                        AuthInfo.shared.token = t
                        NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)
                        ApiDataDownloader.stepics.retrieveCurrentUser(success: { user in
                            AuthInfo.shared.user = user
                            User.removeAllExcept(user)
                            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                            UIThread.performUI { [weak self] in
                                self?.dismissBlock?()
                            }
                        }, error: { _ in
                            print("successfully signed in, but could not get user")
                            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                            UIThread.performUI {
                                [weak self] in
                                self?.dismissBlock?()
                            }
                        })
                    }, failure: { e in
                        switch e {
                        case .existingEmail(_, let email):
                            if let url = URL(string: "\(StepicApplicationsInfo.social?.redirectUri ?? "")?error=social_signup_with_existing_email&email=\(email ?? "")") {
                                UIApplication.shared.openURL(url)
                                SVProgressHUD.dismiss()
                            } else {
                                SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
                            }
                        default:
                            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
                        }
                    })
                }, error: { _ in
                    print("error while social auth")
                    SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
                })
            } else {
                WebControllerManager.sharedManager.presentWebControllerWithURL(getSocialNetworkByIndexPath(indexPath).registerURL, inController: self, withKey: "social auth", allowsSafari: false, backButtonStyle: BackButtonStyle.close, forceCustom: true)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        socialNetworksCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension SocialNetworksViewController : UICollectionViewDelegate {
    func getSocialNetworkByIndexPath(_ indexPath: IndexPath) -> SocialNetwork {
        return socialNetworks[(indexPath as NSIndexPath).item]
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }

//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        UIApplication.sharedApplication().openURL(getSocialNetworkByIndexPath(indexPath).registerURL)
//    }
}

extension SocialNetworksViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialNetworks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialNetworkCollectionViewCell", for: indexPath) as! SocialNetworkCollectionViewCell
        cell.imageView.image = socialNetworks[(indexPath as NSIndexPath).item].image
        return cell
    }
}

extension SocialNetworksViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let usedWidth: CGFloat = CGFloat(socialNetworks.count) * cellSize + CGFloat(socialNetworks.count - 1) * cellSpacing
        let edgeInsets = max((collectionView.frame.size.width - usedWidth) / 2, 0)

        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)

    }
}

extension SocialNetworksViewController: VKSocialSDKProviderDelegate {
    func presentAuthController(_ controller: UIViewController) {
        if let registerURL = SocialNetworks.vk.object.registerURL {
            WebControllerManager.sharedManager.presentWebControllerWithURL(registerURL, inController: self, withKey: "social auth", allowsSafari: false, backButtonStyle: BackButtonStyle.close, forceCustom: true)
        }
    }
}
