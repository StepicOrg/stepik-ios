//
//  SocialNetworksViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SafariServices

class SocialNetworksViewController: UIViewController {

    @IBOutlet weak var socialNetworksCollectionView: UICollectionView!
    
    let socialNetworks = SocialNetworks.all

    
    override func viewDidLoad() {
        super.viewDidLoad()

        socialNetworksCollectionView.delegate = self
        socialNetworksCollectionView.dataSource = self
    
        socialNetworksCollectionView.registerNib(UINib(nibName: "SocialNetworkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SocialNetworkCollectionViewCell")
        
//        print("collection view cancels touches -> \(socialNetworksCollectionView.panGestureRecognizer.cancelsTouchesInView)")
        initializeTapRecognizer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = true
        socialNetworksCollectionView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(sender: UITapGestureRecognizer!) { 
        let location = sender.locationOfTouch(0, inView: socialNetworksCollectionView)
        let locationInCollection = CGPointMake(location.x, location.y)
        let indexPathOptional = socialNetworksCollectionView.indexPathForItemAtPoint(locationInCollection)
        if let indexPath = indexPathOptional {
            WebControllerManager.sharedManager.presentWebControllerWithURL(getSocialNetworkByIndexPath(indexPath).registerURL, inController: self, 
                withKey: "social auth", allowsSafari: false, backButtonStyle: BackButtonStyle.Close)
        }
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        socialNetworksCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension SocialNetworksViewController : UICollectionViewDelegate {
    func getSocialNetworkByIndexPath(indexPath: NSIndexPath) -> SocialNetwork {
        return socialNetworks[indexPath.item]
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        UIApplication.sharedApplication().openURL(getSocialNetworkByIndexPath(indexPath).registerURL)
//    }
}

extension SocialNetworksViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialNetworks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SocialNetworkCollectionViewCell", forIndexPath: indexPath) as! SocialNetworkCollectionViewCell
        cell.imageView.image = socialNetworks[indexPath.item].image
        return cell
    }
}

extension SocialNetworksViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let usedWidth : CGFloat = CGFloat(socialNetworks.count) * 60 + CGFloat(socialNetworks.count - 1) * 10
        let edgeInsets = max((collectionView.frame.size.width - usedWidth) / 2, 0)
        
        return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);

    }
}