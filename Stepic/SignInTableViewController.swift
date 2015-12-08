//
//  SignInTableViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignInTableViewController: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var socialNetworksCollectionView: UICollectionView!

    let socialNetworks : [SocialNetwork] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        
        socialNetworksCollectionView.delegate = self
        socialNetworksCollectionView.dataSource = self
        
        socialNetworksCollectionView.registerNib(UINib(nibName: "SocialNetworkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SocialNetworkCollectionViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        
        let tapG = UITapGestureRecognizer(target: self, action: "tap")
        self.view.addGestureRecognizer(tapG)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func tap() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    @IBAction func signInPressed(sender: UIButton) {
        SVProgressHUD.show()
        AuthentificationManager.sharedManager.logInWithUsername(emailTextField.text!, password: passwordTextField.text!, 
            
            success: {
                t in
                StepicAPI.shared.token = t
                ApiDataDownloader.sharedDownloader.getCurrentUser({
                    user in
                    StepicAPI.shared.user = user
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                    self.performSegueWithIdentifier("signedInSegue", sender: self)
                    AnalyticsHelper.sharedHelper.changeSignIn()
                    AnalyticsHelper.sharedHelper.sendSignedIn()
                    }, failure: {
                        e in
                        print("successfully signed in, but could not get user")
                        SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                        self.performSegueWithIdentifier("signedInSegue", sender: self)
                })
            }, failure: {
                e in
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }
    
    @IBAction func forgotPasswordPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://stepic.org/accounts/password/reset/")!)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignInTableViewController : UICollectionViewDelegate {
    func getSocialNetworkByIndexPath(indexPath: NSIndexPath) -> SocialNetwork {
        return socialNetworks[indexPath.item]
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(getSocialNetworkByIndexPath(indexPath).registerURL)
    }
}

extension SignInTableViewController : UICollectionViewDataSource {
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
