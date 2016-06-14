//
//  WriteCommentViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class WriteCommentViewController: UIViewController {

    @IBOutlet weak var commentTextView: IQTextView!
    
    weak var delegate : WriteCommentDelegate?
    
    var target: Int!
    var parent: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.becomeFirstResponder()
        
        //TODO: Do not forget to localize this
        title = "Comment"
        commentTextView.placeholder = "Write a comment..."

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.sendImage, style: UIBarButtonItemStyle.Done, target: self, action: #selector(WriteCommentViewController.sendPressed))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendPressed() {
        print("send pressed")
        //TODO: Add communication via delegate
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
