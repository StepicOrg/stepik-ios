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
    case editing, sending, ok
}

class WriteCommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextView: IQTextView!
    
    weak var delegate : WriteCommentDelegate?
    
    var state: WriteCommentViewControllerState = .editing {
        didSet {
            UIThread.performUI {
                [weak self] in
                if let s = self {
                    switch s.state {
                    case .sending : 
                        s.navigationItem.rightBarButtonItem = s.sendingItem
                        break
                    case .ok:
                        s.navigationItem.rightBarButtonItem = s.okItem
                        break
                    case .editing: 
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
        editingItem = UIBarButtonItem(image: Images.sendImage, style: UIBarButtonItemStyle.done, target: self, action: #selector(WriteCommentViewController.sendPressed))
        
        let v = UIActivityIndicatorView()
        v.startAnimating()
        sendingItem = UIBarButtonItem(customView: v)
        
        okItem = UIBarButtonItem(image: Images.checkMarkImage, style: UIBarButtonItemStyle.done, target: self, action: Selector())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.becomeFirstResponder()
        
        title = NSLocalizedString("Comment", comment: "")
        commentTextView.placeholder = NSLocalizedString("WriteComment", comment: "")
        setupItems()
        
        state = .editing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var request : Request?
    
    func sendPressed() {
        print("send pressed")
        state = .sending
        sendComment()
    }
    
    var htmlText : String {
        let t = commentTextView.text
        return t.replacingOccurrences(of: "\n", with: "<br>")
    }
    
    func sendComment() {
        let comment = CommentPostable(parent: parent, target: target, text: htmlText)
        
        request = ApiDataDownloader.comments.create(comment, success: 
            {
                [weak self]
                comment in
                self?.state = .ok
                self?.request = nil
                UIThread.performUI {
                    self?.delegate?.didWriteComment(comment)
                    self?.navigationController?.popViewController(animated: true)
                }
            }, error: {
                [weak self]
                errorMsg in
                self?.state = .editing
                self?.request = nil
            }
        )
    }
    

    deinit {
        print("is deiniting")
        request?.cancel()
    }
}

