//
//  UserPreferencesTableViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class UserPreferencesTableViewController: UITableViewController {
    
    @IBOutlet weak var onlyWiFiSwitch: UISwitch!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var videoQualityLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var ignoreMuteSwitchLabel: UILabel!
    @IBOutlet weak var ignoreMuteSwitchSwitch: UISwitch!
    
    
    let heightForRows = [[131], [40, 0, 40], [40]]
    let selectionForRows = [[false], [false, false, true], [true]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        
        avatarImageView.setRoundedBounds(width: 0)

        ignoreMuteSwitchLabel.text = NSLocalizedString("IgnoreMuteSwitch", comment: "")
        
        if let apiUser = StepicAPI.shared.user {
            initWithUser(apiUser)
        } else {
            avatarImageView.image = Constants.placeholderImage
        }
        
        onlyWiFiSwitch.on = !ConnectionHelper.shared.reachableOnWWAN
        ignoreMuteSwitchSwitch.on = AudioManager.sharedManager.ignoreMuteSwitch
        
        ApiDataDownloader.sharedDownloader.getCurrentUser({
            user in
            StepicAPI.shared.user = user
            UIThread.performUI({self.initWithUser(user)})
            }
            , failure: {
            error in
            print("Error while getting current user profile")
            })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    private func initWithUser(user : User) {
        avatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL), placeholderImage: Constants.placeholderImage)
        userNameLabel.text = "\(user.firstName) \(user.lastName)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        videoQualityLabel.text = "\(VideosInfo.videoQuality.rawString)p"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(heightForRows[indexPath.section][indexPath.row])
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectionForRows[indexPath.section][indexPath.row]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 0 {
            signOut()
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func printTokenButtonPressed(sender: UIButton) {
        print(StepicAPI.shared.token?.accessToken)
    }
    
    @IBAction func printDocumentsPathButtonPressed(sender: UIButton) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        print(documentsPath)
    }
    
    
    @IBAction func clearCacheButtonPressed(sender: UIButton) {
    }
    
    @IBAction func allow3GChanged(sender: UISwitch) {
        ConnectionHelper.shared.reachableOnWWAN = !sender.on
    }
    
    @IBAction func ignoreMuteSwitchChanged(sender: UISwitch) {
        AudioManager.sharedManager.ignoreMuteSwitch = sender.on
    }
    
    
    func signOut() {
        StepicAPI.shared.token = nil
    }
    
    @IBAction func signOutButtonPressed(sender: UIButton) {
        signOut()
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("SignInViewController")
//        self.presentViewController(vc, animated: true, completion: {
////            self.dismissViewControllerAnimated(false, completion: nil)
//        })
        
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
