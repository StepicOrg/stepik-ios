//
//  PlayerTestViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PlayerTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    let videoUrl = NSURL(string: "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4")!

    
    @IBAction func showPlayerPressed(sender: UIButton) {
        let player = StepicVideoPlayerViewController(nibName: "StepicVideoPlayerViewController", bundle: nil)
        self.presentViewController(player, animated: true, completion: {
            print("stepic player successfully presented!")
        })
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

}
