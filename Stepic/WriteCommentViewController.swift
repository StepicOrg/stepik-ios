//
//  WriteCommentViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire

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
        
        title = NSLocalizedString("Comment", comment: "")
        commentTextView.placeholder = NSLocalizedString("WriteComment", comment: "")
        setupItems()
        
        state = .Editing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var request : Request?
    
    func sendPressed() {
        print("send pressed")
        state = .Sending
        sendComment()
    }
    
    func sendComment() {
        let comment = CommentPostable(parent: parent, target: target, text: commentTextView.text)
        
        request = ApiDataDownloader.comments.create(comment, success: 
            {
                [weak self]
                comment, userInfo in
                self?.state = .OK
                self?.request = nil
                UIThread.performUI {
                    self?.delegate?.didWriteComment(comment, userInfo: userInfo)
                    self?.navigationController?.popViewControllerAnimated(true)
                }
            }, error: {
                [weak self]
                errorMsg in
                self?.state = .Editing
                self?.request = nil
            }
        )
    }
    

    deinit {
        print("is deiniting")
        request?.cancel()
    }
}

