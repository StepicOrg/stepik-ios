//
//  WriteCommentViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


enum WriteCommentViewControllerState {
    case Editing, Sending, OK
}

class WriteCommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: IQTextView!
    
    weak var delegate : WriteCommentDelegate?
    
    var state: WriteCommentViewControllerState = .Editing {
        didSet {
            UIThread.performUI {
                [weak self] in
                if let s = self {
                    switch s.state {
                    case .Sending : 
                        s.navigationItem.rightBarButtonItem = s.sendingItem
                        break
                    case .OK:
                        s.navigationItem.rightBarButtonItem = s.okItem
                        break
                    case .Editing: 
                        s.navigationItem.rightBarButtonItem = s.editingItem
                        break
                    }
                }
            }
        }
    }
    
    var target: Int!
    var parent: Int?
    
    var editingItem: UIBarButtonItem?
    var sendingItem: UIBarButtonItem?
    var okItem: UIBarButtonItem?
    
    func setupItems() {
        editingItem = UIBarButtonItem(image: Images.sendImage, style: UIBarButtonItemStyle.Done, target: self, action: #selector(WriteCommentViewController.sendPressed))
        
        let v = UIActivityIndicatorView()
        v.startAnimating()
        sendingItem = UIBarButtonItem(customView: v)
        
        okItem = UIBarButtonItem(image: Images.checkMarkImage, style: UIBarButtonItemStyle.Done, target: self, action: Selector())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.becomeFirstResponder()
        
        //TODO: Do not forget to localize this
        title = "Comment"
        commentTextView.placeholder = "Write a comment..."
        setupItems()
        
        state = .Editing
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.sendImage, style: UIBarButtonItemStyle.Done, target: self, action: #selector(WriteCommentViewController.sendPressed))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendPressed() {
        print("send pressed")
        state = .Sending
        delay(1, closure: {
            [weak self] in
            UIThread.performUI {
                self?.state = .OK
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
        })
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

    deinit {
        print("is deiniting")
    }
}

