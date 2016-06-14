//
//  DiscussionAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DiscussionAlertConstructor {
    static func getReplyAlert(replyBlock: (Void->Void)) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Reply", style: .Default, handler: 
            {
                action in
                replyBlock()
            }
        ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        return alert
    }
}